'use strict'

angular.module 'app', ['ui.router']

# Configuration
.config(($urlRouterProvider) ->

  # Default route all to /
  $urlRouterProvider.otherwise('/')
)

.run(($rootScope, $state, DEFAULT_STATE) ->
  
  # Preloading images in memory
  for state in $state.get() when state.controller
    image = new Image()
    image.src = "img/" + state.name + ".png"
    
  # Default state
  $state.go(DEFAULT_STATE)
)