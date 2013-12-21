'use strict';
angular.module('MakoSubs.controllers', ['angularFileUpload']).
  controller('AppCtrl', ['$scope', function($scope) {
  }]).
  controller('CreateSubsCtrl', ['$scope', '$upload', function($scope, $upload) {
    $scope.onFileSelect = function($files) {
      var $file = $files[0];
      $scope.upload = $upload.upload({
        url: '/api/subs',
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
  .controller('ShowSubsCtrl', ['$scope', '$routeParams', 'Subs', function($scope, $routeParams, Subs) {
    $scope.subs = Subs.preview({subsId: $routeParams.subsId});

    $scope.addTranslation = function(line) {
      if (line.transForm.$valid) {
        if(!line.trans)line.trans = [];
        line.trans.push(line.newTran);
        delete line.newTran;

        $scope.subs.$updateTrans({
          subsId: $routeParams.subsId,
          lineId: line.id,
          trans: JSON.stringify(line.trans)
        });
      }
    };

    $scope.isTranslated = function(line) {
      if(line.trans)
        return 'panel-success';
      else
        return 'panel-default';
    };
  }]);
