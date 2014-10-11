'use strict';

toiletControllers.controller('detailController', ['$scope', '$routeParams',
  function($scope, $routeParams) {
    alert("asdasdas");
    $scope.Id = $routeParams.Id;
  }]);