const BundleAnalyzerPlugin = require('webpack-bundle-analyzer').BundleAnalyzerPlugin
const environment = require('./environment')

process.env.NODE_ENV = process.env.NODE_ENV || 'development'

environment.plugins.append('BundleAnalyzer', new BundleAnalyzerPlugin({
  analyzerMode: 'static',
  openAnalyzer: false
}))

module.exports = environment.toWebpackConfig()
