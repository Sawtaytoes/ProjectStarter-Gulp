'use strict'

startTime = (new Date).getTime()
global.__base = __dirname + '/'
global.__gulp = __dirname + '/gulp/globals/'

events = require 'events'
glob = require 'glob-all'
gulp = require 'gulp'
ops = require __gulp + 'ops'

# Fixes "too many watchers" warning
events.EventEmitter.defaultMaxListeners = 0

glob.sync('gulp/tasks/*.+(js|coffee)').forEach (taskName) ->
	require './' + taskName # Pull in Task files


#----------------------------------------
# Global Tasks
#----------------------------------------

gulp.task 'debug', ->
gulp.task 'default', ['dev']

gulp.task 'dev', ops.watchTasks
gulp.task 'dev.clean', ops.mapTasks 'clean'
gulp.task 'dev.build', ops.mapTasks 'build'
gulp.task 'dev.rebuild', ops.mapTasks 'rebuild'
gulp.task 'dev.watch', ops.mapTasks 'watch', ops.watchTasks

# gulp.task('prod', ops.tasks);
# gulp.task('prod.clean', ops.mapTasks('clean'));
# gulp.task('prod.build', ops.mapTasks('build'));
# gulp.task('prod.rebuild', ops.mapTasks('rebuild'));
# gulp.task('prod.watch', ops.mapTasks('watch'));

console.info 'Gulp loaded in ' + ((new Date).getTime() - startTime) * 0.001 + ' seconds'
