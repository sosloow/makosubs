'use strict';
angular.module('MakoSubs.controllers', ['angularFileUpload'])
  .controller('AppCtrl', ['$scope', function($scope) {
  }])
  .controller('CreateSubsCtrl', 
              ['$scope', '$upload', '$http', 'Animus',
               function($scope, $upload, $http, Animus) {

    $scope.subs = {animu: {}};
    $scope.needSearch = false;
    $scope.animuQuery = '';

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

    $scope.searchAnimus = function(query){
      $scope.subs.ep = 1;

      return $http.get('/api/animu/search',
                      {params: {q: query}})
      .then(function(res){
        $scope.animuQuery = query;

        if (query && query.length>4 && res.data.length==0)
          $scope.needSearch = true;
        else
          $scope.needSearch = false;

        return res.data;
      });
    };

    $scope.searchAnn = function(query){
      return $http.get('/api/animu/annsearch',
                      {params: {q: query}})
      .then(function(res){
        return res.data;
      });
    };    

    $scope.getAnimu = function(animu){
      $scope.subs.animu = Animus.get({animuId: animu.id});
    };
  }])
  .controller('ListSubsCtrl', ['$scope', 'Subs', function($scope, Subs) {
    $scope.subsList = Subs.query();
  }])
  .controller('ShowSubsCtrl', 
              ['$scope', '$routeParams', 'Subs', 'Lines',
               function($scope, $routeParams, Subs, Lines) {
      $scope.subs = Subs.get({subsId: $routeParams.subsId});

      $scope.$watch('subs._id.$oid', function(_id){
        if(_id) $scope.lines = Lines.query({subsId: _id});
      });

      $scope.addTranslation = function(line, transForm) {
        if (transForm.$valid) {
          line.$save(function(){
            line.open = false;
            var nextLines = $scope.lines.filter(function(l){
              return !l.trans && $scope.lines.indexOf(line) < $scope.lines.indexOf(l);
            });
            if(nextLines.length>0) nextLines[0].open = true;
          });
        }
      };
  }])
  .controller('ListAnimusCtrl', ['$scope', 'Animus', function($scope, Animus){
  }]);
