'use strict';
angular.module('MakoSubs.services', ['ngResource']).
  factory('Subs', ['$resource', function($resource){ 
    return $resource('/api/subs/:subsId',
                     {subsId: '@subsId'},
                     {preview: {method: 'GET',
                                params:{page: 0,
                                        amount: 100}},
                      updateTrans: {method: 'POST'}
                     });
  }]).
  factory('Lines', ['$resource', function($resource){
    return $resource('/api/subs/:subsId/lines/:lineId',
                     {subsId: '@subsId', lineId: '@lineId'});
  }]);
