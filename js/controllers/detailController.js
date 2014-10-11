'use strict';

toiletControllers.controller('detailController', ['$scope', '$routeParams',
  function($scope, $routeParams) {
    $scope.Id = $routeParams.Id;
  }]);