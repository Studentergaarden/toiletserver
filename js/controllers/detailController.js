'use strict';

toiletControllers.controller('detailController', ['$scope', '$routeParams', '$http', '$filter', 'ngTableParams',
function($scope, $routeParams, $http, $filter, ngTableParams) {


    var requestParems = {
        id: $routeParams.Id,
        to: Date.now(),
        from: Date.now() - 86400000
    };

    var data = [{id:"t1",stamp:1413147412811,ms:68180},
 {id:"t1",stamp:1413149648495,ms:66075},
 {id:"t1",stamp:1413150386061,ms:177867},
 {id:"t1",stamp:1413150973684,ms:80612},
 {id:"t1",stamp:1413153614198,ms:95349},{id:"t1",stamp:1413168087896,ms:172754},{id:"t1",stamp:1413180145164,ms:618016},{id:"t1",stamp:1413181519807,ms:158697},{id:"t1",stamp:1413187681117,ms:87227},{id:"t1",stamp:1413187984432,ms:157513},{id:"t1",stamp:1413191259667,ms:70687},{id:"t1",stamp:1413191859473,ms:152401},{id:"t1",stamp:1413198761976,ms:109173},{id:"t1",stamp:1413199768397,ms:59458},{id:"t1",stamp:1413208624181,ms:554517},{id:"t1",stamp:1413210337092,ms:70886},{id:"t1",stamp:1413213033126,ms:351019},{id:"t1",stamp:1413213598243,ms:73495},{id:"t1",stamp:1413214431056,ms:316227},{id:"t1",stamp:1413223384703,ms:119014},{id:"t1",stamp:1413224450925,ms:1001},{id:"t1",stamp:1413224451264,ms:1002},{id:"t1",stamp:1413224451627,ms:1003},{id:"t1",stamp:1413224451997,ms:1004},{id:"t1",stamp:1413224452383,ms:1005},{id:"t1",stamp:1413225742845,ms:216066},{id:"t1",stamp:1413228920029,ms:50537}];


    
    $scope.tableParams = new ngTableParams({
        page: 1,            // show first page
        count: 10,          // count per page
        sorting: {
            name: 'asc'     // initial sorting
        }
    }, {
        total: data.length, // length of data
        getData: function($defer, params) {
            // use build-in angular filter
            var orderedData = params.sorting() ?
                                $filter('orderBy')(data, params.orderBy()) :
                                data;

            $defer.resolve(orderedData.slice((params.page() - 1) * params.count(), params.page() * params.count()));
        }
    });
}]);  