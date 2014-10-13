'use strict';
// -*- coding: utf-8 -*-

function addZ(n) {
  return (n<10? '0':'') + n;
}

angular.module('format', []).
filter('timeFormat', function() {
  return function(input) {

    var secs = Math.floor(input/1000)%60;
    var mins = Math.floor(input/(1000*60))%60;
    var hrs = Math.floor(input/(1000*60*60))%24;
    var timeStr = '';
    if (hrs > 0)
      timeStr = hrs + '.' + addZ(mins) + ' t';
    else if (mins > 0)
      timeStr = mins + '.' + addZ(secs) + ' min';
    else
      timeStr = secs + ' sek';
    return timeStr;

    //return (hrs) + ':' + (mins) + ':' + (secs);
  };
}).
filter('dateFormat', function() {
  return function(input) {
    /* either return hours in time in UTC or - as commented - local timezone
     * (below) */

    /* Make sure everyone recieves the time exactly as it was on the server */
    var timezoneOffset = (new Date()).getTimezoneOffset() * 60000;
    var date = new Date(input - timezoneOffset);
    return  addZ(date.getUTCHours()) + ':' + addZ(date.getMinutes());
    // var date = new Date(input);
    // return  (date.getHours()) + ':' + date.getMinutes();
  };
});
