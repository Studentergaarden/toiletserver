var toiletApp = angular.module('toiletApp', []);

toiletApp.controller('ToiletController', ['$scope', '$http',
	function ($scope, $http) {
		$http.get('toilets/toilets.json').success(function(data) {
		$scope.toilets = [];
		$scope.showers = [];
		angular.forEach(data, function(value, key) {
			if(value.id == "t1" || value.id == "t2"){
		  		var currentList = $scope.toilets;
				$scope.toilets = currentList.concat(value);
			}else{
		  		var currentList = $scope.showers;
				$scope.showers = currentList.concat(value);
			}
			console.log(value.id)
		});

	});
}]);
