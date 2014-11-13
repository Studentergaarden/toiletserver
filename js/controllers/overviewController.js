// -*- coding: utf-8 -*-
'use strict';

var toiletControllers = angular.module('toiletControllers', ['format','ngTable','ngResource']);

toiletControllers.controller('overviewController', ['$scope','$http',
  function($scope, $http) {
    $http.get(ajaxRoot + 'occupied').success(function(data) {
      $scope.toilets = {};
      $scope.showers = {};

      var date = new Date();
      var now = date.getTime();


      angular.forEach(data, function(value, key) {
        if(value.id == "t1" || value.id == "t2"){
          $scope.toilets[value.id] = value;
          $scope.toilets[value.id].timeLocked = Math.round(now - $scope.toilets[value.id].stamp_state);  
        }else{
          $scope.showers[value.id] = value;
          $scope.showers[value.id].timeLocked = Math.round(now - $scope.showers[value.id].stamp_state);  
         }
        ajaxListener(value.id, $scope, $http);
      });
      console.log($scope.toilets["t1"]);
      
      var timer = setInterval(function(){
        for (var key in $scope.toilets){
          $scope.toilets[key].timeLocked += 1000;
        }

        for (var key in $scope.showers){
          $scope.showers[key].timeLocked += 1000;
        }

        $scope.$apply();    
      }, 1000);  
  });
}]);

function ajaxListener(id, $scope, $http){
  $http({method: 'GET', url: ajaxRoot + 'dump&id='+id}).
    success(function(data, status, headers, config) {

      var date = new Date();
      var now = date.getTime();

      if(data.id == "t1" || data.id == "t2"){
        $scope.toilets[data.id] = data;
        $scope.toilets[data.id].timeLocked = Math.round(now - $scope.toilets[data.id].stamp_state); 
      }else{
        $scope.showers[data.id] = data;
        $scope.showers[data.id].timeLocked = Math.round(now - $scope.showers[data.id].stamp_state);  
      }
      ajaxListener(data.id, $scope, $http);
    }).
      error(function(data, status, headers, config) {
    });
}
