'use strict';
angular.module('MakoSubs.services', ['ngResource'])
  .factory('Subs', ['$resource', function($resource){ 
    return $resource('/api/subs/:subsId',
                     {subsId: '@subsId'});
  }])
  .factory('Lines', ['$resource', function($resource){
    return $resource('/api/subs/:subsId/lines/:lineId',
                     {subsId: '@subs_id.$oid', lineId: '@id'});
  }])
  .factory('Animus', ['$resource', function($resource){
    return $resource('/api/animu/:animuId');
  }]);
