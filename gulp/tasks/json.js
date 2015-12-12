module.exports = (function() {
	var $ = require(__gulp + 'plugins'),
		gulp = require('gulp'),
		ops = require(__gulp + 'ops'),
		path = require('path'),
		paths = require(__gulp + 'paths'),
		taskName = path.parse(__filename).name;


	//----------------------------------------
	// Paths
	//----------------------------------------

	paths.json = {
		src: paths.assets.src + 'json/**/*.json',
		dest: paths.assets.dest + 'json/',
		clean: paths.assets.dest + 'json/'
	};


	//----------------------------------------
	// Tasks
	//----------------------------------------

	ops.setupTasks(taskName);
})();
