var AWS = require('aws-sdk');
var ddb = new AWS.DynamoDB();

exports.handler = async (event) => {
    
    try {
	    const  {id, name} = JSON.parse(event.body);
	    var params = {
		    TableName:'Person',
		    Item: {
			    id : {S: id},
			    name : {S: name}
		    }
	    };
	    var data;
	    var msg;
	    try{

		    data = await ddb.putItem(params).promise();
		    console.log("Pessoa registrada com sucesso! ", data);
		    msg = 'Pessoa registrada com sucesso!';

	    } catch(err){

		    console.log("Erro: ", err);
		    msg = err;

	    }
	    var response = {
		    'statusCode': 200,
		    'body': JSON.stringify({
			    message: msg
		    })
	    };
    } catch (err) {
	    console.log(err);
	    return err;
    }
	
    return response;
};