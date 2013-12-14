'use strict';
angular.module('MakoSubs.controllers', ['angularFileUpload']).
  controller('CreateSubsCtrl', ['$scope', '$upload', function($scope, $upload) {
    $scope.onFileSelect = function($files) {
      var $file = $files[0];
      $scope.upload = $upload.upload({
        url: '/script_upload',
        data: {subs: $scope.subs},
        file: $file
      }).success(function(data, status, headers, config) {
        $scope.subsPreview = data;
        console.log(data);
      });
    };
  }])
    .controller('ListSubsCtrl', ['$scope', 'Subs', function($scope, Subs) {
      $scope.subsList = Subs.query();
    }])
    .controller('ShowSubsCtrl', ['$scope', '$routeParams', 'Subs',
                                 function($scope, $routeParams, Subs) {
      $scope.subs = Subs.get({subsId: $routeParams.subsId});
    }]);
