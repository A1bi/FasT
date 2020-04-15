import { Application } from 'stimulus'
import { definitionsFromContext } from 'stimulus/webpack-helpers'
import { init as initSentry } from '@sentry/browser'

const application = Application.start()
const context = require.context('../controllers', true, /\.js$/)
application.load(definitionsFromContext(context))

if (process.env.NODE_ENV !== 'development') {
  initSentry({
    dsn: 'https://1ba66cdff88948a8a0784eaeb89c5dc2@sentry.a0s.de/2',
    environment: process.env.NODE_ENV
  })
}
