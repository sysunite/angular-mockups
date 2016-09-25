'use strict'

angular.module 'app'

.config ($stateProvider) ->
  $stateProvider
  .state '2',
    url: '/2'
    templateUrl: 'src/modules/img/img.ng.html'
    controller: ($controller, $scope, Region) -> 
      $controller('ImgCtrl', {$scope})

      $scope.regions = [
        Region('1', 179,398,299,499)
        Region('3', 682,396,792,504)
      ]