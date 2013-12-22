'use strict';
angular.module('MakoSubs.controllers', ['angularFileUpload']).
  controller('AppCtrl', ['$scope', function($scope) {
  }]).
  controller('CreateSubsCtrl', ['$scope', '$upload', function($scope, $upload) {
    $scope.onFileSelect = function($files) {
      var $file = $files[0];
      $scope.upload = $upload.upload({
        url: '/api/subs',
        data: {animu: $scope.subs.animu,
               ep: $scope.subs.ep},
        file: $file
      }).success(function(data) {
        $scope.subsPreview = data;
      });
    };
  }])
  .controller('ListSubsCtrl', ['$scope', 'Subs', function($scope, Subs) {
    $scope.subsList = Subs.query();
  }])
  .controller('ShowSubsCtrl', ['$scope', '$routeParams', 'Subs', 'Lines', 
    function($scope, $routeParams, Subs, Lines) {
      $scope.subs = Subs.get({subsId: $routeParams.subsId});

      $scope.$watch('subs._id.$oid', function(_id){
        if(_id) $scope.lines = Lines.query({subsId: _id});
      });

      $scope.addTranslation = function(line, transForm) {
        if (transForm.$valid) {
          line.$save();
        }
      };

      $scope.isTranslated = function(line) {
        if(line.trans)
          return 'panel-success';
        else
          return 'panel-default';
      };
  }]);
