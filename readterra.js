var AWS = require('aws-sdk');
var ddb = new AWS.DynamoDB({apiVersion: '2012-08-10'});

exports.handler = async (event) => {
    
  try {

    const {id} = JSON.parse(event.body);

    var params = {
      TableName:'Person',
      Key: {
        id : {S: id}
      }
    };
    
    var data;
    
    try{

      data = await ddb.getItem(params).promise();
      console.log("Pessoa encontrada com sucesso! ", data);

    } catch(err){

      console.log("Erro: ", err);
      data = err;

    }
    
    var response = {
      'statusCode': 200,
      'body': JSON.stringify({
        message: data
      })
    };
  } catch (err) {
    console.log(err);
    return err;
  }
  return response;
};