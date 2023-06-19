// workaround for sentry-cli not supporting FreeBSD, will run it locally instead
var sentryWebpackPlugin
try {
  sentryWebpackPlugin = require('@sentry/webpack-plugin').sentryWebpackPlugin
} catch (e) {
  if (e.code !== 'MODULE_NOT_FOUND') throw e
}

const environment = require('./environment')

process.env.NODE_ENV = process.env.NODE_ENV || 'production'

if (sentryWebpackPlugin) {
  environment.plugins.append('SentryWebpack', sentryWebpackPlugin({
    url: 'https://glitchtip.a0s.de/',
    org: 'a0s',
    project: 'fast',
    authToken: process.env.SENTRY_AUTH_TOKEN
  }))
}

module.exports = environment.toWebpackConfig()
