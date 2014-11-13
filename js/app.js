// -*- coding: utf-8 -*-
'use strict';

var online = true;
var root = (online) ? "/" : "http://localhost/toiletserver/";
var ajaxRoot = (online) ? '/ajax/' : 'http://toilet/ajax/';


var toiletApp = angular.module('toiletApp', [
  'ngRoute',
  'toiletControllers']);

toiletApp.config(['$routeProvider',
  function($routeProvider) {
    $routeProvider.

    when('/occupy', {
      templateUrl: root + 'partials/occupyOverview.html',
      controller: 'overviewController'
    }).
    when('/occupy/:Id', {
      templateUrl: root + 'partials/occupyDetail.html',
      controller: 'detailController'
    }).
    otherwise({
      redirectTo: '/occupy'
    });
  }
]);

