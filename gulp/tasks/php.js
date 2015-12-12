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

	paths.php = {
		src: paths.assets.src + 'php_scripts/**/*.php',
		dest: paths.assets.dest + 'php_scripts/',
		clean: paths.assets.dest + 'php_scripts/'
	};


	//----------------------------------------
	// Tasks
	//----------------------------------------

	ops.setupTasks(taskName);
})();
