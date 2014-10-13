'use strict';

function ISODateString(d){
 
 return d.getUTCFullYear()+'-'
      + pad(d.getUTCMonth()+1)+'-'
      + pad(d.getUTCDate())+'T'
      + pad(d.getUTCHours())+':'
      + pad(d.getUTCMinutes())+':'
      + pad(d.getUTCSeconds());

  }

 function pad(n){return n<10 ? '0'+n : n}

toiletControllers.controller('detailController', ['$scope', '$routeParams', '$http', '$filter', 'ngTableParams',
function($scope, $routeParams, $http, $filter, ngTableParams) {

	var timezoneOffset = (new Date()).getTimezoneOffset() * 60000;
    
    $scope.from = ISODateString(new Date(Date.now() - timezoneOffset - 86400000));
    $scope.to = ISODateString(new Date(Date.now() - timezoneOffset));
    $scope.occuId = $routeParams.Id;
    
	$scope.tableParams = new ngTableParams({
        page: 1,            // show first page
        count: 10,          // count per page
        sorting: {
        	name: 'asc'     // initial sorting
    	}
	}, 
	{
    	getData: function($defer, params) {
    		console.log(Date.parse($scope.to));
    	
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

		            // use build-in angular filter
		            	var orderedData = params.sorting() ?
		                                $filter('orderBy')(data2, params.orderBy()) :
		                                data2;

		            	$defer.resolve(orderedData.slice((params.page() - 1) * params.count(), params.page() * params.count()));
		      });

		}
	});	  
}]);  


