module.exports = (function() {
	var $ = require(__gulp + 'plugins'),
		browserSync = require('browser-sync').create(),
		del = require('del'),
		glob = require('glob-all'),
		gulp = require('gulp'),
		ops = {},
		path = require('path'),
		paths = require(__gulp + 'paths'),
		vinylPaths = require('vinyl-paths');


	//----------------------------------------
	// Error Handling
	//----------------------------------------

	ops.showError = function(error) {
		$.notify.onError({
			title: 'Gulp',
			subtitle: 'Failure!',
			message: 'Error: <%= error.message %>',
			sound: 'Beep'
		})(error);

		this.emit('end');
	};


	//----------------------------------------
	// Clean
	//----------------------------------------

	ops.clean = function(taskName, src) {
		return gulp.src(src)
			.pipe($.debug({title: taskName}))
			.pipe(vinylPaths(function(filenames) {
				return del(filenames, {force: true});
			}).on('error', ops.showError));
	};


	//----------------------------------------
	// Copy
	//----------------------------------------

	ops.copy = function(taskName, src, dest) {
		var bower = $.filter([
				'**/*',
				'!' + paths.bower.src + '**/*'
			], {
				restore: true,
				passthrough: false
			}),
			stream;

		stream = gulp.src(src, {base: process.cwd()})
			.pipe($.plumber({errorHandler: ops.showError}))
			.pipe(bower)
			.pipe($.rename(function (filePath) {
				filePath.dirname = '.';
			}))
			.pipe($.newer(dest))
			.pipe($.debug({title: taskName}))
			.pipe(gulp.dest(dest))
			.pipe(ops.browserSync.stream());

		bower.restore
			.pipe($.rename(function (filePath) {
				filePath.dirname = paths.bower.getComponentName(filePath.dirname);
			}))
			.pipe($.newer(dest))
			.pipe($.debug({title: taskName}))
			.pipe(gulp.dest(dest))
			.pipe(ops.browserSync.stream());

		return stream;
	};


	//----------------------------------------
	// BrowserSync
	//----------------------------------------

	ops.browserSync = browserSync;

	gulp.task('browserSync', ['browserSync.watch']);
	gulp.task('browserSync.watch', function() {
		var hostname = 'localhost',
			port = '35781';

		try { hostname = require(__gulp + 'machine-address') } catch(err) {}

		return browserSync.init({
			https: true,
			host: hostname,
			port: port,
			logConnections: true,
			notify: false,
			open: false,
			server: true,
			socket: {
				domain: hostname + ':' + port,
			}
		});
	});


	//----------------------------------------
	// Watch
	//----------------------------------------

	ops.watchTasks = ['browserSync'];

	ops.watchStart = function(taskName) {
		console.info('Watcher running for ' + taskName + '...');
	};

	ops.watchChange = function(event) {
		console.info('File ' + path.basename(event.path) + ' was ' + event.type + ', running tasks...');
	};

	ops.watchDelete = function(event, filePaths) {
		var deletedFiles = [],
			deletedFilename = path.parse(event.path).name,
			deletedFilenameLength = deletedFilename.length;

		filePaths = filePaths instanceof Array ? filePaths : [filePaths]

		filePaths.forEach(function(item) {
			glob.sync(item).forEach(function(filename) {
				if (deletedFilename + '.' !== path.parse(filename).name.substr(0, deletedFilenameLength) + '.') {
					return;
				}

				deletedFiles.push(filename)
			});
		});

		return ops.clean('watch.delete', deletedFiles)
			.pipe($.print(function(filename) {
				return 'File ' + path.basename(filename) + ' deleted.';
			}));
	};

	ops.setupWatch = function(taskName) {
		ops.watchTasks.push(taskName);

		gulp.task(taskName, [taskName + '.watch']);

		gulp.task(taskName + '.watch', function() {
			ops.watchStart(taskName);

			return gulp.watch(paths[taskName].src)
				.on('change', function(event) {
					ops.watchChange(event);
					browserSync.reload();
				});
		});
	};


	//----------------------------------------
	// Tasks
	//----------------------------------------

	ops.tasks = [];

	ops.mapTasks = function(suffix, tasks) {
		!tasks && (tasks = ops.tasks);

		return tasks.map(function(taskName) {
			return taskName + '.' + suffix;
		});
	};

	ops.setupTasks = function(taskName, taskBuild) {
		var taskBuildCaller;

		ops.tasks.push(taskName);
		ops.watchTasks.push(taskName);

		!taskBuild && (taskBuild = ops.copy);

		taskBuildCaller = function() {
			return taskBuild(taskName + '.build', paths[taskName].src, paths[taskName].dest);
		};

		gulp.task(taskName, $.synchronize.sync([
			taskName + '.rebuild',
			taskName + '.watch'
		]));

		gulp.task(taskName + '.clean', function() {
			if (paths[taskName].clean) {
				return ops.clean(taskName + '.clean', paths[taskName].clean);
			}

			console.info('No clean for '+ taskName);
			return false;
		});

		gulp.task(taskName + '.build', function() {
			return taskBuildCaller();
		});

		gulp.task(taskName + '.rebuild', $.synchronize.sync([
			taskName + '.clean',
			taskName + '.build'
		]));

		gulp.task(taskName + '.watch', function() {
			ops.watchStart(taskName);

			return gulp.watch(paths[taskName].src, function(event) {
				var gulpStream;

				ops.watchChange(event);

				if (paths[taskName].clean && event.type === 'deleted') {
					gulpStream = ops.watchDelete(event, paths[taskName].dest + '**/*')
				} else {
					gulpStream = taskBuildCaller()
				}

				return gulpStream
			});
		});
	};


	//----------------------------------------
	//----------------------------------------

	return ops;
})();
