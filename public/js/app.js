'use strict';
angular.module('MakoSubs', [
  'ngRoute',
  'ui.bootstrap',
  'MakoSubs.filters',
  'MakoSubs.services',
  'MakoSubs.directives',
  'MakoSubs.controllers'
]).
config(['$routeProvider', '$locationProvider', function($routeProvider, $locationProvider) {
  $routeProvider
    .when('/subs/new', {templateUrl: 'partials/create_subs.html', controller: 'CreateSubsCtrl'})
    .when('/subs/?', {templateUrl: 'partials/list_subs.html', controller: 'ListSubsCtrl'})
    .when('/subs/:subsId', {templateUrl: 'partials/show_subs.html', controller: 'ShowSubsCtrl'})
    .when('/animu/?', {templateUrl: 'partials/list_animu.html', controller: 'ListSubsCtrl'})
    .when('/b/?', {templateUrl: 'partials/messageboard.html', controller: 'MessageBoardCtrl'})
    .otherwise({redirectTo: '/'});
  $locationProvider.html5Mode(true);
}]);
