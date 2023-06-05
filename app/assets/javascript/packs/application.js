import 'core-js/stable'
import 'regenerator-runtime/runtime'
import { Application } from 'stimulus'
import { definitionsFromContext } from 'stimulus/webpack-helpers'
import { init as initSentry } from '@sentry/browser'

import '../components/dynamic_colors'
import '../components/header'
import '../components/forms'
import '../components/carousel'
import '../components/page_nav'

const application = Application.start()
const context = require.context('../controllers', true, /\.js$/)
application.load(definitionsFromContext(context))

require('@rails/ujs').start()

if (process.env.NODE_ENV !== 'development') {
  initSentry({
    dsn: 'https://2d0c454fb3414c4dafe0ac4736913ec3@glitchtip.a0s.de/1',
    environment: process.env.NODE_ENV
  })
}
