'use strict';
angular.module('MakoSubs', [
  'ngRoute',
  'MakoSubs.filters',
  'MakoSubs.services',
  'MakoSubs.directives',
  'MakoSubs.controllers'
]).
config(['$routeProvider', function($routeProvider) {
  $routeProvider.when('/subs/new', {templateUrl: 'partials/create_subs.html', controller: 'CreateSubsCtrl'});
  $routeProvider.when('/subs/?', {templateUrl: 'partials/list_subs.html', controller: 'ListSubsCtrl'});
  $routeProvider.when('/subs/:subsId', {templateUrl: 'partials/subs_details.html', controller: 'SubsDetailsCtrl'});
  $routeProvider.otherwise({redirectTo: '/subs'});
}]);
