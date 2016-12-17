var http = require("http");
var https = require("https");
var querystring = require("querystring");
var fs = require('fs');

function getPred(data) {
	console.log('===getPred()===');
	var dataString = JSON.stringify(data)



	//header
	var host = 'ussouthcentral.services.azureml.net'
	var path = '/workspaces/bd7ad4350c2245faab8796d385b1c5e5/services/e72bbfc04d7d44c69684ec7fe0cc9140/execute?api-version=2.0&details=true'
	var method = 'POST'
	var api_key = 'dVAp//lYFZksMfEW3FhRvbelXbCvDGf7vj/SXKyf6k8gHpBEk/dV53SYODMF+hcxmprXla4KKVN6IcAgRb9l/w=='
	var headers = {'Content-Type':'application/json', 'Authorization':'Bearer ' + api_key}; 

	var options = {

		host: host,
		port: 443,
		path: path,
		method: method,
		headers: headers

	};

 	console.log('data: ' + data);
 	console.log('method: ' + method);
	console.log('api_key: ' + api_key);
	console.log('headers: ' + headers);
	console.log('options: ' + options);


	//request 1 packet
 	var reqPost = https.request(options, function (res) {
		console.log('===reqPost()===');
		console.log('StatusCode: ', res.statusCode);
		console.log('headers: ', res.headers);

		//response
 		res.on('data', function(d) {
			process.stdout.write(d);
		});

	});

	// Would need more parsing out of prediction from the result
	reqPost.write(dataString);
	reqPost.end();
	reqPost.on('error', function(e){
		console.error(e);
	});
}

//Could build feature inputs from web form or RDMS. This is the new data that needs to be passed to the web service.
function buildFeatureInput(){
	console.log('===performRequest()===');
	var data = {
		"Inputs": {
			"input1": {
				"ColumnNames": ["tweet_text"],
				"Values": [ [ "iphone hahahahaha!!!!!!!!!!!!!!" ], ]
			},
		},
		"GlobalParameters": {}
	}

	getPred(data);

}

 
function send404Reponse(response) {
	response.writeHead(404, {"Context-Type": "text/plain"});
	response.write("Error 404: Page not Found!");
	response.end();
}

function onRequest(request, response) {
	if(request.method == 'GET' && request.url == '/' ){
		response.writeHead(200, {"Context-Type": "text/plain"});
		fs.createReadStream("./index.html").pipe(response);
	}else {
		send404Reponse(response);
	}
}
 

http.createServer(onRequest).listen(8050);

console.log("Server is now running on port 8050");

buildFeatureInput();








