import 'core-js/stable'
import 'regenerator-runtime/runtime'
import { Application } from 'stimulus'
import { definitionsFromContext } from 'stimulus/webpack-helpers'
import { init as initSentry } from '@sentry/browser'
import { testWebPSupport } from '../components/utils'

(async () => {
  // polyfill for IE 11
  if (!window.Element.prototype.matches) await import('@stimulus/polyfills')
})()

document.addEventListener('DOMContentLoaded', async () => {
  const supported = await testWebPSupport()
  document.body.classList.add(`${supported ? '' : 'no-'}webp`)
})

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
