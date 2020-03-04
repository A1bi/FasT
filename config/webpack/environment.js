const { environment } = require('@rails/webpacker')

environment.config.externals = {
  jquery: 'jQuery',
  moment: 'moment'
}

module.exports = environment
