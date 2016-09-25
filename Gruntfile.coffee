# Using exclusion patterns slows down Grunt significantly
# instead of creating a set of patterns like '**/*.js' and '!**/node_modules/**'
# this method is used to create a set of inclusive patterns for all subdirectories
# skipping node_modules, bower_components, dist, and any .dirs
# This enables users to create any directory structure they desire.
createFolderGlobs = (fileTypePatterns) ->
  if not Array.isArray(fileTypePatterns)
    fileTypePatterns = [fileTypePatterns]

  ignore = ['node_modules', 'bower_components', 'dist', 'tmp', 'server']
  fs = require('fs')

  map = (file) ->
    if (ignore.indexOf(file) isnt -1 or file.indexOf('.') is 0 or not fs.lstatSync(file).isDirectory())
      return null
    else
      return fileTypePatterns.map((pattern) -> return file + '/**/' + pattern)

  return fs.readdirSync(process.cwd()).map((file) -> map(file)).filter((patterns) -> return patterns).concat(fileTypePatterns)


module.exports = (grunt) ->

  # Load all grunt tasks
  require('load-grunt-tasks')(grunt)

  # Task configuration
  grunt.initConfig(
    connect:
      main:
        options:
          livereload: 35742
          open: false
          port: 9066
          hostname: '0.0.0.0'
          base: ['.', 'src']

    watch:
      main:
        options:
          livereload: 35742
          livereloadOnError: false
          spawn: false

        files: [createFolderGlobs(['*.js', '*.css', '*.html', '*.coffee']), '!_SpecRunner.html', '!.grunt']
        tasks: [] # All the tasks are run dynamically during the watch event handler

    clean:
      before:
        src:['dist', 'tmp']
      after:
        src:['tmp']


    # Automatically inject Bower components into the app
    wiredep:
      app:
        src: ['src/index.html']
        cwd: 'src'
        bowerJson: require('./bower.json')
        directory: 'bower_components'
        ignorePath: '../'


    # Compiles CoffeeScript to JavaScript
    coffee:
      main:
        options:
          sourceRoot: ''
          sourceMap: false  # Enable when coffee is also copied to tmp

        src: createFolderGlobs('*.coffee')
        dest: 'tmp'
        expand: true
        ext: '.js'


    ngtemplates:
      main:
        options:
          module: 'app'
          htmlmin:'<%= htmlmin.main.options %>'

        src: [createFolderGlobs('*.ng.html')]
        dest: 'tmp/templates.js'


    copy:
      main:
        files: [
          {cwd: 'src/img/', src: ['**'], dest: 'dist/img/', expand: true}
          {cwd: 'src/static/', src: ['**'], dest: 'dist/static/', expand: true}
        ]
      app:
        files: [
          {src: ['tmp/app.js'], dest: 'dist/app.js', expand: false}
        ]

    dom_munger:
      read:
        options:
          read:[
            {selector:'script[in-production!="false"]', attribute:'src', writeto:'appjs'}
            {selector:'link[rel="stylesheet"][in-production!="false"]', attribute:'href', writeto:'appcss'}
          ]

        src: 'src/index.html'

      update:
        options:
          remove: ['script', 'link[rel="stylesheet"]']
          append: [
            {selector: 'body', html:'<script src="app.js"></script>'}
            {selector:'head', html:'<link rel="stylesheet" href="app.css">'}
          ]

        src:'src/index.html'
        dest: 'dist/index.html'

    cssmin:
      main:
        src:['src/main.css', '<%= dom_munger.data.appcss %>']
        dest:'dist/app.css'

    concat:
      main:
        src: ['<%= dom_munger.data.appjs %>', '<%= ngtemplates.main.dest %>']
        dest: 'tmp/app.js'


    ngAnnotate:
      main:
        src:'tmp/app.js'
        dest: 'tmp/app.js'


    uglify:
      main:
        src: 'tmp/app.js'
        dest:'dist/app.js'


    htmlmin:
      main:
        options:
          collapseBooleanAttributes: true
          collapseWhitespace: true
          removeAttributeQuotes: true
          removeComments: true
          removeEmptyAttributes: true
          removeScriptTypeAttributes: true
          removeStyleLinkTypeAttributes: true

        files:
          'dist/index.html': 'dist/index.html'


    imagemin:
      main:
        files: [
          expand: true, cwd:'dist/'
          src:['**/*.png', '*.jpg']
          dest: 'dist/'
        ]
  )

  grunt.registerTask('default', ['clean:after', 'coffee', 'connect', 'watch'])
  grunt.registerTask('wire', ['wiredep'])
  grunt.registerTask('build',['clean:before', 'coffee', 'dom_munger','ngtemplates','cssmin','concat','ngAnnotate','copy:main', 'copy:app', 'htmlmin','imagemin','clean:after'])


  grunt.event.on('watch', (action, filepath) ->

    tasksToRun = []

    if (filepath.lastIndexOf('.coffee') isnt -1 and filepath.lastIndexOf('.coffee') is filepath.length - 7)
      tasksToRun.push('coffee')


    if (filepath.lastIndexOf('.js') isnt -1 and filepath.lastIndexOf('.js') is filepath.length - 3)

      # Find the appropriate unit test for the changed file
      spec = filepath
      if (filepath.lastIndexOf('-spec.js') is -1 || filepath.lastIndexOf('-spec.js') isnt filepath.length - 8)
        spec = filepath.substring(0,filepath.length - 3) + '-spec.js'


      # if the spec exists then lets run it
      if (grunt.file.exists(spec))
        files = [].concat(grunt.config('dom_munger.data.appjs'))
        files.push('bower_components/angular-mocks/angular-mocks.js')
        files.push(spec)
        grunt.config('karma.options.files', files)
        tasksToRun.push('karma:during_watch')


    # if index.html changed, we need to reread the <script> tags so our next run of karma
    # will have the correct environment
    if (filepath is 'src/index.html')
      tasksToRun.push('dom_munger:read')


    grunt.config('watch.main.tasks',tasksToRun)

  )