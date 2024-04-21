# frozen_string_literal: true

pin 'application', preload: true

pin '@hotwired/stimulus', to: 'stimulus.min.js', preload: true
pin '@hotwired/stimulus-loading', to: 'stimulus-loading.js', preload: true
pin '@rails/ujs', to: 'rails-ujs.esm.js', preload: true
pin '@rails/actioncable', to: 'actioncable.esm.js'
pin 'socket.io-client' # @4.4.1
pin 'filepond' # @4.28.2
pin 'filepond-plugin-image-preview' # @4.6.7
pin 'filepond-plugin-file-validate-type' # @1.2.6
pin 'glightbox' # @3.2.0
pin 'chart.js' # @2.9.3
pin 'moment' # @2.29.4
pin 'mapbox-gl' # @1.11.0
pin 'qrcode-svg' # @4.30.4

pin_all_from 'app/javascript/controllers', under: 'controllers'
pin_all_from 'app/javascript/components', under: 'components'

pin 'colorthief', to: 'https://unpkg.com/colorthief@2.4.0/dist/color-thief.mjs'
pin 'pdfjs', to: 'https://unpkg.com/pdfjs-dist@4.0.269/build/pdf.min.mjs'
pin 'pdfjs-worker', to: 'https://unpkg.com/pdfjs-dist@4.0.269/build/pdf.worker.min.mjs'
