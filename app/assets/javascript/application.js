import { Application } from '@hotwired/stimulus'
import { eagerLoadControllersFrom } from '@hotwired/stimulus-loading'
import { init as initSentry } from '@sentry/browser'
import '@rails/ujs'

import './components/dynamic_colors'
import './components/header'
import './components/forms'
import './components/carousel'
import './components/page_nav'

initSentry({
  dsn: 'https://2d0c454fb3414c4dafe0ac4736913ec3@glitchtip.a0s.de/1',
  denyUrls: ['http://localhost']
})

const application = Application.start()
eagerLoadControllersFrom('controllers', application)
