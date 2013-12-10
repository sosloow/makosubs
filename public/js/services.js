'use strict';
angular.module('MakoSubs.services', ['ngResource'])
  .factory('Subs', ['$resource', function($resource){ 
    return $resource('/subs/:subsId'); 
  }]);
