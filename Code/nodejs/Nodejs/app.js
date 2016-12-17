// var eventList = document.getElementById("eventlist");
// var evtSource = new EventSource("http://localhost:4000/msg");

// var newElement = document.createElement("li");
// newElement.innerHTML = "Messages:";
// eventList.appendChild(newElement);


// evtSource.onmessage = function(e) {
//     console.log("received event");
//     console.log(e);
//     var newElement = document.createElement("li");

//     newElement.innerHTML = "message: " + e.data;
//     eventList.appendChild(newElement);
// };      

// evtSource.onerror = function(e) {
//     console.log("EventSource failed.");
// };

// console.log(evtSource);

// (function(){
//     angular
//         .module('twitterstreamanalysis', [])
//         .controller('todocontroller', todocontroller);

 
//     function todocontroller($scope, $http){
//     	 console.log("getcontoller");
//     	$scope.getText = function(){
//     		var p = $http({
//       			method: 'GET',
//       			url: '/twitter'
//     		});
//     		p.success(function(response, status, headers, config){
//         		$scope.name = response.name;
//     		});
//     	}

//   	}
// })();
