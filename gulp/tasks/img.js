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

	paths.img = {
		src: paths.assets.src + 'img/**/*.+(gif|jpg|png|svg)',
		dest: paths.assets.dest + 'img/',
		clean: paths.assets.dest + 'img/'
	};


	//----------------------------------------
	// Operations
	//----------------------------------------

	ops.img = {};

	ops.img.build = function(taskName, src, dest) {

		return gulp.src(src)
			.pipe($.plumber({errorHandler: ops.showError}))
			.pipe($.newer({dest: dest}))
			.pipe($.debug({title: taskName}))

			// Minification
			.pipe($.imagemin({
				interlaced: true,
				progressive: true,
				svgoPlugins: [{removeViewBox: false}],
				use: [$.imageminPngQuant()]
			}))

			// Write File
			.pipe(gulp.dest(dest))
			.pipe(ops.browserSync.stream());
	};


	//----------------------------------------
	// Tasks
	//----------------------------------------

	ops.setupTasks(taskName, ops[taskName].build);
})();
