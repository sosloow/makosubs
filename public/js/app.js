'use strict';
angular.module('myApp', [
  'ngRoute',
  'myApp.filters',
  'myApp.services',
  'myApp.directives',
  'myApp.controllers'
]).
config(['$routeProvider', function($routeProvider) {
  $routeProvider.when('/subs/new', {templateUrl: 'partials/new_subs.html', controller: 'MyCtrl1'});
  $routeProvider.when('/subs', {templateUrl: 'partials/list_subs.html', controller: 'MyCtrl2'});
  $routeProvider.otherwise({redirectTo: '/view1'});
}]);
