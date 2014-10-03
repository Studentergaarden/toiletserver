// -*- coding: utf-8 -*-



function addZ(n) {
  /* add  padding in forms of 0's. Eg. 7 -> 07 */
  return (n<10? '0':'') + n;
}

angular.module('toiletFilter', []).
filter('timeFormat', function() {
  return function(input) {

    secs=Math.floor(input/1000)%60;
    mins=Math.floor(input/(1000*60))%60;
    hrs=Math.floor(input/(1000*60*60))%24;
    var timeStr = '';
    if (hrs > 0)
      timeStr = hrs + '.' + addZ(mins) + ' t';
    else if (mins > 0)
      timeStr = mins + '.' + addZ(secs) + ' min';
    else
      timeStr = secs + ' sek';
    return timeStr;

    //return (hrs) + ':' + (mins) + ':' + (secs);
  };
}).
filter('dateFormat', function() {
  return function(input) {
    /* either return hours in time in UTC or - as commented - local timezone
     * (below) */

    /* Make sure everyone recieves the time exactly as it was on the server */
    timezoneOffset = (new Date()).getTimezoneOffset() * 60000;
    var date = new Date(input - timezoneOffset);
    return  addZ(date.getUTCHours()) + ':' + addZ(date.getMinutes());
    // var date = new Date(input);
    // return  (date.getHours()) + ':' + date.getMinutes();
  };
});


var toiletApp = angular.module('toiletApp', ['toiletFilter']);

var loki = false;
var loki = true;
if (loki == true){
  str_url = '/ajax/';
}else{
  str_url = 'http://toilet/ajax/';
}


toiletApp.controller('ToiletController', ['$scope', '$http',
	function ($scope, $http) {
		$http.get(str_url + 'occupied').success(function(data) {
		$scope.toilets = {};
		$scope.showers = {};
		angular.forEach(data, function(value, key) {
			if(value.id == "t1" || value.id == "t2"){
				$scope.toilets[value.id] = value;
			}else{
				$scope.showers[value.id] = value;
			}
          ajaxListener(value.id, $scope, $http);
		});
	});
}]);


function ajaxListener(id, $scope, $http){
	console.log(id);
	$http({method: 'GET', url: str_url + 'dump&id='+id}).
		success(function(data, status, headers, config) {
			if(data.id == "t1" || data.id == "t2"){
				$scope.toilets[data.id] = data;
			}else{
				$scope.showers[data.id] = data;
			}
			ajaxListener(data.id, $scope, $http);
		}).
	  	error(function(data, status, headers, config) {
	 		console.log("Something went wrong in ajaxListener:controller.js");
		});
}



function DatatableCtrl($scope) {
  $scope.headers = [
    { "order": 1, "width": 0, "label": "ID", "data": "id", "type": "string", "visible": false },
    { "order": 2, "width": 120, "label": "Last Name", "data": "lastName", "type": "string", "visible": true },
    { "order": 3, "width": 129, "label": "First Name", "data": "firstName", "type": "string", "visible": true },
    { "order": 4, "width": 200, "label": "Email Address", "data": "email", "type": "string", "visible": true },
    { "order": 5, "width": 120, "label": "Phone Number", "data": "phoneNumber", "type": "string", "visible": true },
    { "order": 6, "width": 80, "label": "Username", "data": "username", "type": "string", "visible": true },
    { "order": 7, "width": 100, "label": "Last Login", "data": "lastLoginDate", "type": "date", "visible": true }
  ];

  $scope.headerOrder = "order";
  $scope.headerFilter = function(header) {
    return header.visible;
  };
  $scope.users = [
    { "id": "1", "lastName": "Test1", "firstName": "Test", "email": "test1@example.com", "phoneNumber": "(555) 111-0001", "username": "ttest1", lastLoginDate: "12/28/2012 3:51 PM" },
    { "id": "2", "lastName": "Test2", "firstName": "Test", "email": "test2@example.com", "phoneNumber": "(555) 222-0002", "username": "ttest2", lastLoginDate: "12/28/2012 3:52 PM" },
    { "id": "3", "lastName": "Test3", "firstName": "Test", "email": "test3@example.com", "phoneNumber": "(555) 333-0003", "username": "ttest3", lastLoginDate: "12/28/2012 3:53 PM" },
    { "id": "4", "lastName": "Test4", "firstName": "Test", "email": "test4@example.com", "phoneNumber": "(555) 444-0004", "username": "ttest4", lastLoginDate: "12/28/2012 3:54 PM" },
    { "id": "5", "lastName": "Test5", "firstName": "Test", "email": "test5@example.com", "phoneNumber": "(555) 555-0005", "username": "ttest5", lastLoginDate: "12/28/2012 3:55 PM" }
  ];

  $scope.rowDoubleClicked = function(user) {
    console.log("Username: " + user.username);
  };
  $scope.counter = 0;

  $scope.userOrder = function(key) {
    console.log("key="+key);//prints: "key=undefined"
    angular.forEach($scope.headers, function(header){
      if(header.data == key)
      {
        if(header.visible) {
          return header.order;
        }
      }
    });
    return -1;
  };
}
