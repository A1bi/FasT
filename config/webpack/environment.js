const { environment } = require('@rails/webpacker')

// prevent Babel from transpiling node-modules
environment.loaders.delete('nodeModules')

module.exports = environment
