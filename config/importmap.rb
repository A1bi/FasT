# frozen_string_literal: true

pin 'application', preload: true

pin '@hotwired/stimulus', to: 'stimulus.min.js', preload: true
pin '@hotwired/stimulus-loading', to: 'stimulus-loading.js', preload: true
pin '@rails/ujs', to: '@rails--ujs.js', preload: true # @7.0.5
pin '@rails/actioncable', to: 'actioncable.esm.js'
pin 'jquery', preload: true # @3.5.1
pin 'socket.io-client' # @4.4.1
pin 'filepond' # @4.28.2
pin 'filepond-plugin-image-preview' # @4.6.7
pin 'filepond-plugin-file-validate-type' # @1.2.6
pin 'chart.js' # @2.9.3
pin 'moment' # @2.29.4
pin 'mapbox-gl' # @1.11.0
pin 'qrcode-svg' # @4.30.4

pin_all_from 'app/javascript/controllers', under: 'controllers'
pin_all_from 'app/javascript/components', under: 'components'
