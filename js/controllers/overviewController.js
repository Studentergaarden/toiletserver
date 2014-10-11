'use strict';

var loki = true;
var str_url = '/ajax/';

if (!loki){
  str_url = 'http://toilet/ajax/';
}

var toiletControllers = angular.module('toiletControllers', ['toiletFilter']);

toiletControllers.controller('overviewController', ['$scope','$http', '$routeParams',
  function($scope, $http, $routeParams) {
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
  $http({method: 'GET', url: str_url + 'dump&id='+id}).
    success(function(data, status, headers, config) {
      $scope.toilets[data.id] = data;
      ajaxListener(data.id, $scope, $http);
    }).
      error(function(data, status, headers, config) {
    });
}