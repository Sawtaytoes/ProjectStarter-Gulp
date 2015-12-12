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

	paths.blade =
		src: paths.pages.src + '**/*.blade.php'
		dest: paths.pages.dest


	#----------------------------------------
	# Tasks
	#----------------------------------------

	ops.setupWatch taskName
