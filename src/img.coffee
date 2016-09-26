'use strict'

angular.module 'app'

.controller('ImgCtrl', ($scope, $state, $window, $timeout) ->
  
  # The name of the state should correspond to an image in the img folder
  $scope.img = $state.current.name

  # Console log the coordinates for easy coordinate tracking
  $scope.click = (event) ->
    console.log(event.offsetX + ',' + event.offsetY)

  # Head to the right state
  $scope.toState = (state) ->
    $state.go(state)

  # To account for screen resizing, translate the coordinates
  $scope.translate = (width, height, x1, y1, x2, y2) ->
    x1 = x1 * $scope.width / width
    y1 = y1 * $scope.height / height

    x2 = x2 * $scope.width / width
    y2 = y2 * $scope.height / height

    x1 + ',' + y1 + ',' + x2 + ',' + y2

  # Called when the window resizes
  $scope.resize = ->
    $('body').height($(window).height());

    $timeout((->
      $scope.width  = $('#image').width()
      $scope.height = $('#image').height()
    ), 200)

  # Listen for resize events
  angular.element($window).bind('resize', ->
    $scope.resize()
    $scope.$digest();
  )
  
  # Initially call resize function
  $scope.resize()
)
