'use strict';

var toiletControllers = angular.module('toiletControllers', ['format','ngTable','ngResource']);

toiletControllers.controller('overviewController', ['$scope','$http',
  function($scope, $http) {
    $http.get(ajaxRoot + 'occupied').success(function(data) {
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
  $http({method: 'GET', url: ajaxRoot + 'dump&id='+id}).
    success(function(data, status, headers, config) {
      if(data.id == "t1" || data.id == "t2"){
        $scope.toilets[data.id] = data;
      }else{
        $scope.showers[data.id] = data;
      }
      ajaxListener(data.id, $scope, $http);
    }).
      error(function(data, status, headers, config) {
    });
}
