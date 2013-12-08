'use strict';
angular.module('MakoSubs.controllers', ['angularFileUpload']).
  controller('CreateSubsCtrl', ['$scope', '$upload', function($scope, $upload) {
    $scope.onFileSelect = function($files) {
      var $file = $files[0];
      $scope.upload = $upload.upload({
        url: '/subs/new',
        data: {subs: $scope.subs},
        file: $file
      }).success(function(data, status, headers, config) {
        console.log(data);
      });
    };
  }])
  .controller('ListSubsCtrl', [function() {

  }]);
