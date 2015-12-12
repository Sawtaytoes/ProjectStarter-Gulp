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

	paths.css = {
		src: paths.assets.src + 'scss/**/*.+(sass|scss)',
		dest: paths.assets.dest + 'css/',
		clean: paths.assets.dest + 'css/'
	};


	//----------------------------------------
	// Operations
	//----------------------------------------

	ops.css = {};

	ops.css.build = function(taskName, src, dest) {
		return gulp.src(src)
			.pipe($.plumber({errorHandler: ops.showError}))
			.pipe($.filter(['**/!(_)*']))
			.pipe($.newer({
				dest: dest,
				ext: '.css'
			}))
			.pipe($.debug({title: taskName}))

			// Sass -> CSS
			.pipe($.sourcemaps.init())
			.pipe($.sass({
				// directory: __base,
				errLogToConsole: true,
				includePaths: [
					paths.bower.datetimepicker.src,
					paths.bower.fontawesome.src + 'scss/',
					paths.bower.foundation.src + 'scss/',
					paths.bower.slick.src
				],
				outputStyle: 'expanded'
			}).on('error', $.sass.logError))

			// Prefix
			.pipe($.autoprefixer({
				browsers: [
					'last 2 versions',
					'> 5%',
					'ie 10-11',
					'not ie <= 9' // Might be redundant
				]
			}))

			// Write Files
			// .pipe($.sourcemaps.write('.'))
			// .pipe(gulp.dest(dest))
			// .pipe(browserSync.stream({match: '**/*.css'}));

			// Remove Map Files
			.pipe($.filter('*.css'))

			// Minify
			.pipe($.minifyCss({
				debug: true,
				keepSpecialComments: 0,
				mediaMerging: true,
				roundingPrecision: 3,
				semanticMerging: true
			}))

			// Write Minified Files
			// .pipe($.rename({suffix: '.min'}))
			.pipe($.sourcemaps.write('.'))
			.pipe(gulp.dest(dest))
			.pipe(ops.browserSync.stream({match: '**/*.css'}));
	};


	//----------------------------------------
	// Tasks
	//----------------------------------------

	ops.setupTasks(taskName, ops[taskName].build);
})();
