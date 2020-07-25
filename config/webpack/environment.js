const { environment } = require('@rails/webpacker')

environment.splitChunks()

// exclude unused moment library (imported by chartjs)
environment.config.externals = {
  moment: 'moment'
}

module.exports = environment
