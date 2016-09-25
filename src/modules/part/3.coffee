'use strict'

angular.module 'app'

.config ($stateProvider) ->
  $stateProvider
  .state '3',
    url: '/3'
    templateUrl: 'src/modules/img/img.ng.html'
    controller: ($controller, $scope, Region) -> 
      $controller('ImgCtrl', {$scope})

      $scope.regions = [
        Region('1', 179,398,299,499)
        Region('2', 433,397,550,492)
      ]