module.exports = do ->
	$ = require __gulp + 'plugins'
	browserSync = require 'browser-sync'
		.create()
	del = require 'del'
	glob = require 'glob-all'
	gulp = require 'gulp'
	ops = {}
	path = require 'path'
	paths = require __gulp + 'paths'
	vinylPaths = require 'vinyl-paths'


	##----------------------------------------
	## Error Handling
	##----------------------------------------

	ops.showError = (error) ->
		$.notify.onError(
			title: 'Gulp'
			subtitle: 'Failure!'
			message: 'Error: <%= error.message %>'
			sound: 'Beep'
		) error

		@emit 'end'


	##----------------------------------------
	## Clean
	##----------------------------------------

	ops.clean = (taskName, src) ->
		gulp.src src
			.pipe $.debug title: taskName
			.pipe vinylPaths((filenames) ->
				del filenames, force: true
			).on 'error', ops.showError


	##----------------------------------------
	## Copy
	##----------------------------------------

	ops.copy = (taskName, src, dest) ->
		bower = $.filter [
			'**/*'
			'!' + paths.bower.src + '**/*'
		],
		restore: true
		passthrough: false

		stream = gulp.src(src, base: process.cwd())
			.pipe $.plumber(errorHandler: ops.showError)
			.pipe bower
			.pipe $.rename (filePath) ->
				filePath.dirname = '.'
			.pipe $.newer dest
			.pipe $.debug title: taskName
			.pipe gulp.dest dest
			.pipe ops.browserSync.stream()

		bower.restore
			.pipe $.rename (filePath) ->
				filePath.dirname = paths.bower.getComponentName filePath.dirname
			.pipe $.newer dest
			.pipe $.debug title: taskName
			.pipe gulp.dest dest
			.pipe ops.browserSync.stream()

		stream


	##----------------------------------------
	## BrowserSync
	##----------------------------------------

	ops.browserSync = browserSync

	gulp.task 'browserSync', ['browserSync.watch']
	gulp.task 'browserSync.watch', ->
		hostname = 'localhost'
		port = '35781'

		try hostname = require __gulp + 'machine-address'

		browserSync.init
			https: true
			host: hostname
			port: port
			logConnections: true
			notify: false
			open: false
			server: true
			socket: domain: hostname + ':' + port


	##----------------------------------------
	## Watch
	##----------------------------------------

	ops.watchTasks = ['browserSync']

	ops.watchStart = (taskName) ->
		console.info 'Watcher running for ' + taskName + '...'

	ops.watchChange = (event) ->
		console.info 'File ' + path.basename(event.path) + ' was ' + event.type + ', running tasks...'

	ops.watchDelete = (event, filePaths) ->
		deletedFiles = []
		deletedFilename = path.parse(event.path).name
		deletedFilenameLength = deletedFilename.length

		filePaths = if filePaths instanceof Array then filePaths else [ filePaths ]
		filePaths.forEach (item) ->
			glob.sync(item).forEach (filename) ->
				if deletedFilename + '.' != path.parse(filename).name.substr(0, deletedFilenameLength) + '.'
					return

				deletedFiles.push filename

		ops.clean('watch.delete', deletedFiles)
			.pipe $.print (filename) ->
				'File ' + path.basename(filename) + ' deleted.'

	ops.setupWatch = (taskName) ->
		ops.watchTasks.push taskName

		gulp.task taskName, [taskName + '.watch']

		gulp.task taskName + '.watch', ->
			ops.watchStart taskName

			gulp.watch paths[taskName].src
				.on 'change', (event) ->
					ops.watchChange event
					browserSync.reload()


	##----------------------------------------
	## Tasks
	##----------------------------------------

	ops.tasks = []

	ops.mapTasks = (suffix, tasks) ->
		!tasks and tasks = ops.tasks

		tasks.map (taskName) ->
			taskName + '.' + suffix

	ops.setupTasks = (taskName, taskBuild) ->
		ops.tasks.push taskName
		ops.watchTasks.push taskName

		!taskBuild and (taskBuild = ops.copy)

		taskBuildCaller = ->
			taskBuild taskName + '.build', paths[taskName].src, paths[taskName].dest

		gulp.task taskName, $.synchronize.sync [
			taskName + '.rebuild'
			taskName + '.watch'
		]

		gulp.task taskName + '.clean', ->
			if paths[taskName].clean
				return ops.clean(taskName + '.clean', paths[taskName].clean)

			console.info 'No clean for ' + taskName
			false

		gulp.task taskName + '.build', ->
			taskBuildCaller()

		gulp.task taskName + '.rebuild', $.synchronize.sync [
			taskName + '.clean'
			taskName + '.build'
		]

		gulp.task taskName + '.watch', ->
			ops.watchStart taskName

			gulp.watch paths[taskName].src, (event) ->
				ops.watchChange event

				if paths[taskName].clean and event.type == 'deleted'
					gulpStream = ops.watchDelete event, paths[taskName].dest + '**/*'
				else
					gulpStream = taskBuildCaller()

				gulpStream


	##----------------------------------------
	##----------------------------------------

	ops
