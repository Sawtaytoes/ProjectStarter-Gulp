module.exports = do ->
	$ = require __gulp + 'plugins'
	gulp = require 'gulp'
	mergeStream = require 'merge-stream'
	ops = require __gulp + 'ops'
	path = require 'path'
	paths = require __gulp + 'paths'
	stream = require 'stream'
	taskName = path.parse(__filename).name


	#----------------------------------------
	# Paths
	#----------------------------------------

	paths.js =
		src: paths.assets.src + 'js/**/*.+(es6|js)'
		dest: paths.assets.dest + 'js/'
		clean: paths.assets.dest + 'js/'
		mangle: true

	paths.js.modernizr = src: paths.bower.foundation.src + 'js/vendor/modernizr.js'

	paths.js.foundation =
		src: [
			paths.bower.foundation.src + 'js/vendor/jquery.cookie.js'
			paths.bower.foundation.src + 'js/vendor/fastclick.js'
			paths.bower.foundation.src + 'js/foundation/foundation.js'
			paths.bower.foundation.src + 'js/foundation/foundation.abide.js'
			paths.bower.foundation.src + 'js/foundation/foundation.accordion,.js'
			paths.bower.foundation.src + 'js/foundation/foundation.alert.js'
			paths.bower.foundation.src + 'js/foundation/foundation.clearing.js'
			paths.bower.foundation.src + 'js/foundation/foundation.dropdown.js'
			paths.bower.foundation.src + 'js/foundation/foundation.equalizer.js'
			paths.bower.foundation.src + 'js/foundation/foundation.interchange.js'
			paths.bower.foundation.src + 'js/foundation/foundation.joyride.js'
			paths.bower.foundation.src + 'js/foundation/foundation.magellan.js'
			paths.bower.foundation.src + 'js/foundation/foundation.offcanvas.js'
			paths.bower.foundation.src + 'js/foundation/foundation.orbit.js' # Deprecated
			paths.bower.foundation.src + 'js/foundation/foundation.reveal.js'
			paths.bower.foundation.src + 'js/foundation/foundation.slider.js'
			paths.bower.foundation.src + 'js/foundation/foundation.tab.js'
			paths.bower.foundation.src + 'js/foundation/foundation.tooltip.js'
			paths.bower.foundation.src + 'js/foundation/foundation.topbar.js'
			paths.bower.foundation.src + 'js/vendor/jquery.placeholder.js'
		]
		mangle: true

	paths.js.vendor = src: [
		paths.bower.src + 'jquery/dist/jquery.js'
		paths.bower.jqueryui.src + 'ui/core.js'
		paths.bower.jqueryui.src + 'ui/widget.js'
		paths.bower.jqueryui.src + 'ui/position.js'
		paths.bower.jqueryui.src + 'ui/menu.js'
		paths.bower.jqueryui.src + 'ui/autocomplete.js'
		paths.bower.src + 'jquery-easing/jquery.easing.js'
		paths.bower.datetimepicker.src + 'jquery.datetimepicker.js'
		paths.bower.src + 'velocity/velocity.js'
		paths.bower.src + 'underscore/underscore.js'
		paths.bower.src + 'backbone/backbone.js'
		paths.bower.slick.src + 'slick.js'
	]


	#----------------------------------------
	# Operations
	#----------------------------------------

	ops.js = {}

	ops.js.build = (taskName, src, dest) ->
		commonStream = gulp.src src, base: process.cwd()
			.pipe $.plumber errorHandler: ops.showError
			.pipe $.rename (filePath) ->
				filePath.dirname = filePath.dirname.replace path.normalize paths.assets.src + 'js/', ''

			# Start Sourcemapping
			.pipe $.newer dest
			.pipe $.debug title: taskName

			# ES6 -> ES5
			.pipe $.sourcemaps.init()
			.pipe $.babel(
				comments: false
				only: '*.es6'
			).on'error', ops.showError

			# Write File
			# .pipe $.sourcemaps.write '.'
			# .pipe gulp.dest dest

		commonStream = ops.js.minify(commonStream, paths.js.mangle, dest)
		gulpStream = mergeStream(commonStream, new stream)

		gulpStream.add ops.js.buildVendor(taskName, paths.js.modernizr.src, dest,
			subTaskName: 'modernizr'
			mangle: paths.js.modernizr.mangle)
		gulpStream.add ops.js.buildVendor(taskName, paths.js.foundation.src, dest,
			subTaskName: 'foundation'
			mangle: paths.js.foundation.mangle)
		gulpStream.add ops.js.buildVendor(taskName, paths.js.vendor.src, dest,
			subTaskName: 'vendor'
			mangle: paths.js.vendor.mangle)

		gulpStream

	ops.js.buildVendor = (taskName, src, dest, options) ->
		gulpStream = gulp.src src
			.pipe $.plumber errorHandler: ops.showError
			.pipe $.newer dest + options.subTaskName + '.js'

			.pipe $.sourcemaps.init()
			.pipe $.concat options.subTaskName + '.js'
			# .pipe $.sourcemaps.write '.'

			.pipe $.debug title: taskName + '-' + options.subTaskName
			# .pipe gulp.dest dest

		ops.js.minify gulpStream, options.mangle, dest

	ops.js.minify = (gulpStream, mangle, dest) ->
		gulpStream

			# Remove Map Files
			.pipe $.filter ['**/*.js']

			# Minify
			# .pipe $.stripDebug()
			.pipe $.uglify(
				mangle: mangle
				output: screw_ie8: true
			).on 'error', ops.showError

			# Write Minified File
			# .pipe $.rename suffix: '.min'
			.pipe $.sourcemaps.write '.'
			.pipe gulp.dest dest
			.pipe ops.browserSync.stream match: '**/*.js'


	#----------------------------------------
	# Tasks
	#----------------------------------------

	ops.setupTasks taskName, ops[taskName].build
