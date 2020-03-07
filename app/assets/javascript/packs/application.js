import { Application } from 'stimulus'
import { definitionsFromContext } from 'stimulus/webpack-helpers'
import { init as initSentry } from '@sentry/browser'

const application = Application.start()
const context = require.context('../controllers', true, /\.js$/)
application.load(definitionsFromContext(context))

let environment = 'production'
const host = window.location.hostname
if (host.indexOf('staging') > -1) {
  environment = 'staging'
// either contains .local TLD (mDNS resolved) or no TLD
} else if (host.indexOf('.local') > -1 || host.indexOf('.') < 0) {
  environment = 'development'
}

if (environment === 'development') {
  initSentry({
    dsn: 'https://1ba66cdff88948a8a0784eaeb89c5dc2@sentry.a0s.de/2',
    environment: environment
  })
}
