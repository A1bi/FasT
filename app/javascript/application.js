import { Application } from '@hotwired/stimulus'
import { eagerLoadControllersFrom } from '@hotwired/stimulus-loading'
import { init as initSentry } from 'components/sentry'
import Rails from '@rails/ujs'

import 'components/header'
import 'components/forms'
import 'components/carousel'
import 'components/page_nav'
import 'components/ruler_color'

initSentry({
  dsn: 'https://2d0c454fb3414c4dafe0ac4736913ec3@glitchtip.a0s.de/1'
})

Rails.start()

const application = Application.start()
eagerLoadControllersFrom('controllers', application)
