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
  }])
  .factory('Threads', ['$resource', function($resource){
    return $resource('/api/threads/:page',
                     {},
                     {query: {method: 'GET', url: '/api/threads/:page', 
                              isArray: true, params: {page: 0}},
                     get: {method: 'GET', url: '/api/threads/res/:threadId'},
                     save: {method: 'POST', url:'/api/threads/res/:threadId', 
                            params: {threadId: '@_id.$oid'}}});
  }]);
