// -*- coding: utf-8 -*-
'use strict';


function pad(n){return n<10 ? '0'+n : n}

function ISODateString(d){

 return d.getUTCFullYear()+'-'
      + pad(d.getUTCMonth()+1)+'-'
      + pad(d.getUTCDate())+'T'
      + pad(d.getUTCHours())+':'
      + pad(d.getUTCMinutes())+':'
      + pad(d.getUTCSeconds());
  }


toiletControllers.controller('detailController', ['$scope', '$routeParams', '$http', '$filter', 'ngTableParams',
function($scope, $routeParams, $http, $filter, ngTableParams) {

    var timezoneOffset = (new Date()).getTimezoneOffset() * 60000;
    var hej = 23;
    $scope.from = ISODateString(new Date(Date.now() - timezoneOffset - 86400000));
    $scope.to = ISODateString(new Date(Date.now() - timezoneOffset));
    $scope.occuId = $routeParams.Id;

    $scope.tableParams = new ngTableParams({
        count: 0,          // count per page
        sorting: {
        	stamp: 'desc'     // initial sorting
    	}
	},
	{
    	getData: function($defer, params) {
    		$http({
		    	method: 'GET',
		    	url: ajaxRoot + 'since&'+$.param(
						{
					        id: $scope.occuId,
					        to: Date.parse($scope.to),
					        from: Date.parse($scope.from)
					    }
		    		),
		    }).success(function(data2) {
		            	var orderedData = params.sorting() ?
		                                $filter('orderBy')(data2, params.orderBy()) :
		                                data2;

		            	$defer.resolve(orderedData.slice((params.page() - 1) * params.count(), data2.length));
		      });
		},
		counts: []
	});	  
}]);  


