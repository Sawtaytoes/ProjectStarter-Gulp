module.exports = do ->
	path = require('path')
	paths = {}


	##----------------------------------------
	## Assets
	##----------------------------------------

	paths.assets =
		src: 'src/assets/'
		dest: 'web/assets/'


	##----------------------------------------
	## Pages
	##----------------------------------------

	paths.pages =
		src: 'src/views/'
		dest: 'src/views/'


	##----------------------------------------
	## Bower
	##----------------------------------------

	paths.bower = src: 'bower_components/'
	paths.bower.fontawesome = src: paths.bower.src + 'font-awesome/'
	paths.bower.foundation = src: paths.bower.src + 'foundation/'
	paths.bower.slick = src: paths.bower.src + 'slick.js/slick/'

	paths.bower.getComponentName = (dirname) ->
		dirname.split(path.sep)[1]


	##----------------------------------------
	##----------------------------------------

	paths
