provider "aws" {
    region = "us-east-1"
}

resource "aws_dynamodb_table" "ddbtable" {
    name             = "Person"
    hash_key         = "id"
    billing_mode   = "PROVISIONED"
    read_capacity  = 5
    write_capacity = 5
    attribute {
        name = "id"
        type = "S"
    }
}


resource "aws_iam_role_policy" "write_policy" {
    name = "lambda_write_policy"
    role = aws_iam_role.writeRole.id

    policy = file("./writeRole/write_policy.json")
}


resource "aws_iam_role_policy" "read_policy" {
    name = "lambda_read_policy"
    role = aws_iam_role.readRole.id

    policy = file("./readRole/read_policy.json")
}


resource "aws_iam_role" "writeRole" {
    name = "myWriteRole"
    assume_role_policy = file("./writeRole/assume_write_role_policy.json")
}


resource "aws_iam_role" "readRole" {
    name = "myReadRole"
    assume_role_policy = file("./readRole/assume_read_role_policy.json")

}


resource "aws_lambda_function" "writeLambda" {
    function_name = "writeLambda"
    s3_bucket     = "dio-terraform-bucket"
    s3_key        = "writeterra.zip"
    role          = aws_iam_role.writeRole.arn
    handler       = "writeterra.handler"
    runtime       = "nodejs14.x"
}


resource "aws_lambda_function" "readLambda" {
    function_name = "readLambda"
    s3_bucket     = "dio-terraform-bucket"
    s3_key        = "readterra.zip"
    role          = aws_iam_role.readRole.arn
    handler       = "readterra.handler"
    runtime       = "nodejs14.x"
}



resource "aws_api_gateway_rest_api" "apiLambda" {
    name        = "terraAPI"

}


resource "aws_api_gateway_resource" "writeResource" {
    rest_api_id = aws_api_gateway_rest_api.apiLambda.id
    parent_id   = aws_api_gateway_rest_api.apiLambda.root_resource_id
    path_part   = "writedb"

}


resource "aws_api_gateway_method" "writeMethod" {
    rest_api_id   = aws_api_gateway_rest_api.apiLambda.id
    resource_id   = aws_api_gateway_resource.writeResource.id
    http_method   = "POST"
    authorization = "NONE"
}


resource "aws_api_gateway_resource" "readResource" {
    rest_api_id = aws_api_gateway_rest_api.apiLambda.id
    parent_id   = aws_api_gateway_rest_api.apiLambda.root_resource_id
    path_part   = "readdb"

}


resource "aws_api_gateway_method" "readMethod" {
    rest_api_id   = aws_api_gateway_rest_api.apiLambda.id
    resource_id   = aws_api_gateway_resource.readResource.id
    http_method   = "POST"
    authorization = "NONE"
}




resource "aws_api_gateway_integration" "writeInt" {
   rest_api_id = aws_api_gateway_rest_api.apiLambda.id
   resource_id = aws_api_gateway_resource.writeResource.id
   http_method = aws_api_gateway_method.writeMethod.http_method

   integration_http_method = "POST"
   type                    = "AWS_PROXY"
   uri                     = aws_lambda_function.writeLambda.invoke_arn
   
}


resource "aws_api_gateway_integration" "readInt" {
   rest_api_id = aws_api_gateway_rest_api.apiLambda.id
   resource_id = aws_api_gateway_resource.readResource.id
   http_method = aws_api_gateway_method.readMethod.http_method

   integration_http_method = "POST"
   type                    = "AWS_PROXY"
   uri                     = aws_lambda_function.readLambda.invoke_arn

}



resource "aws_api_gateway_deployment" "apideploy" {
   depends_on = [ aws_api_gateway_integration.writeInt, aws_api_gateway_integration.readInt]

   rest_api_id = aws_api_gateway_rest_api.apiLambda.id
   stage_name  = "dev"
}


resource "aws_lambda_permission" "writePermission" {
   statement_id  = "AllowExecutionFromAPIGateway"
   action        = "lambda:InvokeFunction"
   function_name = aws_lambda_function.writeLambda.function_name
   principal     = "apigateway.amazonaws.com"

   source_arn = "${aws_api_gateway_rest_api.apiLambda.execution_arn}/dev/POST/writedb"

}


resource "aws_lambda_permission" "readPermission" {
   statement_id  = "AllowExecutionFromAPIGateway"
   action        = "lambda:InvokeFunction"
   function_name = aws_lambda_function.readLambda.function_name
   principal     = "apigateway.amazonaws.com"

   source_arn = "${aws_api_gateway_rest_api.apiLambda.execution_arn}/dev/POST/readdb"

}


output "base_url" {
  value = aws_api_gateway_deployment.apideploy.invoke_url
}