'use strict'

angular.module 'app'

.factory('Region', (DEFAULT_MOCKUP_SIZE) ->
  (state, x1, y1, x2, y2, width, height) ->
    
    width  = DEFAULT_MOCKUP_SIZE.width  if not width?
    height = DEFAULT_MOCKUP_SIZE.height if not height?
    
    {"shape": "rect", state, x1, y2, x2, y2, width, height}
)