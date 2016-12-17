var Twit = require('twit');
var express = require('express');
var cp = require("child_process");
var http = require('http')

var io = require('socket.io').listen(server);
var app = express(),
	server = require('http').createServer(app),
	io = io.listen(server);

//
//var http = require("http");
var https = require("https");
var querystring = require("querystring");
var fs = require('fs');
var sleep = require('sleep');

server.listen((process.env.PORT || 3000));
app.use(express.static(__dirname + '/'));
//app.get('/', function(req,res){res.sendFile('/chart.html');});
function getPred(type, data) {
	//print a header
	var host = 'ussouthcentral.services.azureml.net';
	var path = '/workspaces/bd7ad4350c2245faab8796d385b1c5e5/services/e72bbfc04d7d44c69684ec7fe0cc9140/execute?api-version=2.0&details=true';
	var method = 'POST';
	var api_key = 'dVAp//lYFZksMfEW3FhRvbelXbCvDGf7vj/SXKyf6k8gHpBEk/dV53SYODMF+hcxmprXla4KKVN6IcAgRb9l/w==';
	var headers = {
		'Content-Type': 'application/json',
		'Authorization': 'Bearer ' + api_key
	};

	var options = {

		host: host,
		port: 443,
		path: path,
		method: method,
		headers: headers

	};

	//console.log('data: ' + data);
	// console.log('method: ' + method);
	// console.log('api_key: ' + api_key);
	// console.log('headers: ' + headers);
	// console.log('options: ' + options);

	//POST request model using options of header
	sleep.usleep(500000);
	var reqPost = https.request(options, function (res) {
		// console.log('===reqPost()===');
		// console.log('StatusCode: ', res.statusCode);
		// console.log('headers: ', res.headers);

		//response
		res.on('data', function (d) {
			var data = JSON.parse(d.toString());
			try {
				var emotion = data.Results.output1.value.Values[0][0];
				io.sockets.emit('stream', {
					type: type,
					emotion: emotion
				});
			} catch (e) {
				console.log('SERVICE UNAVAILABLE BECAUSE OF THROTTLING');
			}

			// process.stdout.write(d);
		});

	});

	reqPost.on('error', function (e) {
		console.error(e);
	});
	//request practice
	var dataString = JSON.stringify(data);
	// console.log(dataString);
	reqPost.write(dataString + '\n');
	reqPost.end();
}

var T = new Twit({
	consumer_key: 'd24IisrcWzA5lQnO4lTBGUBHQ',
	consumer_secret: 'gkUIic91hf34BfnHhgE86zEEp2yqe87aGV3tVN4SNW0Pabez8l',
	access_token: '806234759437385728-6YIowuhV2hCWQ4oHDKEBWkf6ILRwxy0',
	access_token_secret: 'uTV7uEQMeAf8tc4AWVGzZHx3fgJFyNUXKrZMBsENsbi68',
	timeout_ms: 60 * 1000, // optional HTTP request timeout to apply to all requests.
});
var ipadStream, iphoneStream;
io.sockets.on('connection', function (socket) {

	console.log('Connected');

	socket.on('disconnect', function () {
		console.log('Disconnected');
		if (ipadStream) {
			ipadStream.stop();
		}

		if (iphoneStream) {
			iphoneStream.stop();
		}
	});

	ipadStream = T.stream('statuses/filter', {
		track: 'ipad',
		language: 'en'
	});

	ipadStream.on('tweet', function (tweet) {
		console.log('fetching data...');
		var inputText = tweet.text.replace(/[^A-Za-z0-9\s:punct://]/g, '').replace(/^\s+/g, '').replace(/\s+$/g, '').replace(/\s+/g, ' ');
		// console.log('===performRequest()===');
		var data = {
			"Inputs": {
				"input1": {
					"ColumnNames": ["tweet_text"],
					"Values": [
						[inputText],
					]
				},
			},
			"GlobalParameters": {}
		}
		getPred('ipad', data);
		io.sockets.emit('ipadStream', inputText);
		//console.log(tweet.text);
	});

	iphoneStream = T.stream('statuses/filter', {
		track: 'iphone',
		language: 'en'
	});

	iphoneStream.on('tweet', function (tweet) {
		console.log('fetching data...');
		var inputText = tweet.text.replace(/[^A-Za-z0-9\s:punct://]/g, '').replace(/^\s+/g, '').replace(/\s+$/g, '').replace(/\s+/g, ' ');
		// console.log('===performRequest()===');
		var data = {
			"Inputs": {
				"input1": {
					"ColumnNames": ["tweet_text"],
					"Values": [
						[inputText],
					]
				},
			},
			"GlobalParameters": {}
		}
		getPred('iphone', data);
		io.sockets.emit('iphoneStream', inputText);
		//console.log(tweet.text);
	});

});