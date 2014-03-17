'use strict';
angular.module('MakoSubs.directives', []).
  directive('ngEnter', function () {
    return function (scope, element, attrs) {
      element.bind("keydown keypress", function (event) {
        if(event.which === 13) {
          scope.$apply(function (){
            scope.$eval(attrs.ngEnter);
          });

          event.preventDefault();
        }
      });
    };
  }).directive('focusMe', function($timeout, $parse) {
    return {
      link: function(scope, element, attrs) {
        var model = $parse(attrs.focusMe);
        scope.$watch(model, function(value) {
          if(value === true) { 
            $timeout(function() {
              element[0].focus(); 
            });
          }
        });
      }
    };
  }).directive('thread', function(){
    return {
      restrict: 'A',
      replace: true,
      templateUrl: 'partials/thread.html',
      scope: {
        thread: '=',
        limit: '='
      },
      link: function(scope, element, attrs) {
        scope.$watch('open', function(open) {
          if (open)
            scope.filteredPosts = scope.thread.posts;
          else
            scope.filteredPosts = scope.thread.posts.slice(-scope.limit);
        });
      },
      controller: ['$scope', function($scope) {
        $scope.open = false;
        $scope.showForm = false;
        $scope.buttonText = function(open) {
          return open ? 'Свернуть' : 'Развернуть';
        };
        $scope.toggleThread = function(){
          $scope.open = !$scope.open;
        };

        $scope.toggleForm = function(){
          $scope.showForm = !$scope.showForm;
        };

        $scope.postPost = function(){
          $scope.thread.$save({body: $scope.newPost},
            function(data){
            console.log(data);
            $scope.showForm = false;
          });
        };
      }]
    };
  });
