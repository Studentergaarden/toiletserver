// -*- coding: utf-8 -*-
'use strict';

toiletControllers.controller('graphController', ['$scope','$routeParams','$http',
  	function($scope, $routeParams, $http) {
		var timezoneOffset = (new Date()).getTimezoneOffset() * 60000;
		
		var beforeOneWeek = new Date(new Date().getTime() - 60 * 60 * 24 * 14 * 1000 - timezoneOffset)
		  , day = beforeOneWeek.getDay()
		  , diffToMonday = beforeOneWeek.getDate() - day + (day === 0 ? -6 : 1)
		  , lastMonday = new Date(beforeOneWeek.setDate(diffToMonday));

		var lastMondayISO = Date.parse(lastMonday);
  		var params = $.param(
						{
					        from: lastMondayISO,
					        to: Date.parse(ISODateString(new Date(Date.now() - timezoneOffset)))
					    }
		    			);
  		

  		var accumulatedDays = new Array(3);

		for(var i = 0; i < 3; i++) {
		    accumulatedDays[i] = new Array(7);
		    for(var j = 0; j < 7; j++){
		    	accumulatedDays[i][j] = 0;
		    }
		}
  		
  		$http({
	    	method: 'GET',
	    	url: ajaxRoot + 'since&id='+$routeParams.Id+'&' + params
	    }).success(function(data) {
			data.forEach(function(entry) {
				var timeFromMonday = entry.stamp - lastMondayISO;
				var index = ((timeFromMonday - timeFromMonday % (1000 * 60 * 60 * 24))) / 86400000;
				var temp = accumulatedDays[(index - index % 7) / 7][index % 7];
				accumulatedDays[(index - index % 7) / 7][index % 7] = temp + entry.ms / 1000;
			});	
			
	    	var graphlines = new Array(3);
			
			for (var i = 0; i < 3; i++) { 
				graphlines[i] = [];
				for(var j = 0; j < 7; j++){
			    	graphlines[i].push([j + 1,accumulatedDays[i][j]]);
			    }
			}

			var stack = 0,
				bars = false,
				lines = true,
				steps = false;	

			$.plot("#placeholder", graphlines, {
				series: {
					stack: false,
					lines: {
						show: lines,
						fill: true,
						steps: steps
					},
					bars: {
						show: bars,
						barWidth: 0.6
					}
				}
			});
  		});

		
}]);

