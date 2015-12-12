module.exports = do ->
	$ = require __gulp + 'plugins'
	gulp = require 'gulp'
	ops = require __gulp + 'ops'
	path = require 'path'
	paths = require __gulp + 'paths'
	taskName = path.parse(__filename).name


	#----------------------------------------
	# Paths
	#----------------------------------------

	paths.font =
		src: [
			paths.assets.src + 'font/**/*'
			paths.bower.fontawesome.src + 'fonts/*'
			paths.bower.slick.src + 'fonts/*'
		]
		dest: paths.assets.dest + 'font/'
		clean: paths.assets.dest + 'font/'


	#----------------------------------------
	# Tasks
	#----------------------------------------

	ops.setupTasks taskName
