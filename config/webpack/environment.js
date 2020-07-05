const { environment } = require('@rails/webpacker')

// prevent Babel from transpiling node-modules
environment.loaders.delete('nodeModules')

environment.splitChunks()

// exclude unused moment library (imported by chartjs)
environment.config.externals = {
  moment: 'moment'
}

module.exports = environment
