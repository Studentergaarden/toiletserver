// -*- coding: utf-8 -*-

angular.module('toiletFilter', []).
filter('timeFormat', function() {
	return function(input) {

      // function addZ(n) {
      //   return (n<10? '0':'') + n;
      // }

      secs=Math.floor(input/1000)%60;
      mins=Math.floor(input/(1000*60))%60;
      hrs=Math.floor(input/(1000*60*60))%24;
      var timeStr = '';
      if (hrs > 0)
        timeStr = hrs + '.' + mins + ' t';
      else if (mins > 0)
        timeStr = mins + '.' + secs + ' min';
      else
        timeStr = secs + ' sek';
      return timeStr;

      //return (hrs) + ':' + (mins) + ':' + (secs);
    };
}).
filter('dateFormat', function() {
  return function(input) {
    timezoneOffset = (new Date()).getTimezoneOffset() * 60000;
    var date = new Date(input - timezoneOffset);
    // return date.getDate() + '.' + date.getMonth() + ' ' +
    return  (date.getHours() - 2) + ':' + date.getMinutes();
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
				ajaxListener(value.id, $scope, $http);
			}else{
				$scope.showers[value.id] = value;
			}
		});
	});
}]);


function ajaxListener(id, $scope, $http){
	console.log(id);
	$http({method: 'GET', url: str_url + 'dump&id='+id}).
		success(function(data, status, headers, config) {
			$scope.toilets[data.id] = data;
			ajaxListener(data.id, $scope, $http);
			console.log("adsads");
		}).
	  	error(function(data, status, headers, config) {
	 		console.log("Chaos Chaos Chaos");
		});
}
