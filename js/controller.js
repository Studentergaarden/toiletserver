var toiletApp = angular.module('toiletApp', []);

toiletApp.controller('ToiletController', ['$scope', '$http',
	function ($scope, $http) {
		$http.get('http://toilet/ajax/occupied').success(function(data) {
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
	$http({method: 'GET', url: 'http://toilet/ajax/dump&id='+id}).
		success(function(data, status, headers, config) {
			$scope.toilets[data.id] = data;
			ajaxListener(data.id, $scope, $http);
		}).
	  	error(function(data, status, headers, config) {
	 		console.log("Chaos Chaos Chaos");
		});
}