# Shorthand function to allow for quick mapping

angular.mockup = (img, callback) ->
  angular.module 'app'

  .config ($stateProvider) ->
    $stateProvider
    .state img,
      url: '/' + img
      templateUrl: 'src/img.ng.html'
      controller: ($controller, $scope, Region) ->
        
        # Call parent controller
        $controller('ImgCtrl', {$scope})

        # This holds an array of regions
        class Regions
          constructor: ->
            @list = []

          map: (x1, y1, x2, y2, width, height) ->
            to: (state) =>
              @list.push(Region(state, x1, y1, x2, y2, width, height))

        regions = new Regions()
        callback(regions.map.bind(regions))   # Binding so that regions becomes available in the map function
        $scope.regions = regions.list