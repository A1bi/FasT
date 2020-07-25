const { environment } = require('@rails/webpacker')

// prevent Babel from transpiling mapbox-gl
// https://github.com/mapbox/mapbox-gl-js/issues/3422
const nodeModulesLoader = environment.loaders.get('nodeModules')
nodeModulesLoader.exclude = [/mapbox-gl/]

environment.splitChunks()

// exclude unused moment library (imported by chartjs)
environment.config.externals = {
  moment: 'moment'
}

module.exports = environment
