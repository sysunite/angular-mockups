'use strict'

angular.module 'app'

.config ($stateProvider) ->
  $stateProvider
  .state '1',
    url: '/1'
    templateUrl: 'src/modules/img/img.ng.html'
    controller: ($controller, $scope, Region) -> 
      $controller('ImgCtrl', {$scope})

      $scope.regions = [
        Region('2', 433, 397, 550, 492)
        Region('3', 682, 396, 792, 504)
      ]