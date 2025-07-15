# frozen_string_literal: true

pin 'application', preload: true

pin '@github/webauthn-json/browser-ponyfill', to: '@github--webauthn-json--browser-ponyfill.js' # @2.1.1
pin '@hotwired/stimulus', to: 'stimulus.min.js', preload: true
pin '@hotwired/stimulus-loading', to: 'stimulus-loading.js', preload: true
pin '@rails/ujs', to: 'rails-ujs.esm.js', preload: true
pin '@rails/actioncable', to: 'actioncable.esm.js'
pin '@stripe/stripe-js', to: 'stripe-js.js' # @3.5.0
pin 'chart.js' # @2.9.3
pin 'dayjs' # @1.11.13
pin 'dayjs-locale-de' # @1.11.13
pin 'dayjs-plugin-relative-time' # @1.11.13
pin 'filepond' # @4.28.2
pin 'filepond-plugin-file-validate-type' # @1.2.6
pin 'filepond-plugin-image-preview' # @4.6.7
pin 'glightbox' # @3.2.0
pin 'mapbox-gl' # @1.11.0
pin 'moment' # @2.29.4
pin 'moment/min/moment-with-locales', to: 'moment--min--moment-with-locales.js' # @2.30.1
pin 'qrcode-svg' # @4.30.4
pin 'socket.io-client' # @4.4.1
pin 'sortablejs' # @1.15.2

pin_all_from 'app/javascript/controllers', under: 'controllers'
pin_all_from 'app/javascript/components', under: 'components'

pin 'colorthief', to: 'https://unpkg.com/colorthief@2.4.0/dist/color-thief.mjs'
pin 'pdfjs', to: 'https://unpkg.com/pdfjs-dist@4.0.269/build/pdf.min.mjs'
pin 'pdfjs-worker', to: 'https://unpkg.com/pdfjs-dist@4.0.269/build/pdf.worker.min.mjs'
