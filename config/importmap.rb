# frozen_string_literal: true

pin 'application', preload: true

pin 'stimulus', to: 'stimulus.min.js', preload: true
pin '@hotwired/stimulus', to: 'stimulus.min.js', preload: true
pin '@hotwired/stimulus-loading', to: 'stimulus-loading.js', preload: true
pin '@rails/ujs', to: 'https://cdn.jsdelivr.net/npm/@rails/ujs@7.0.5/+esm', preload: true
pin '@rails/actioncable', to: 'https://cdn.jsdelivr.net/npm/@rails/actioncable@7.0.5/+esm'
pin '@sentry/browser', to: 'https://cdn.jsdelivr.net/npm/@sentry/browser@7.56.0/+esm', preload: true
pin 'socket.io-client', to: 'https://cdn.jsdelivr.net/npm/socket.io-client@4.7.0/+esm'
pin 'jquery', to: 'https://cdn.jsdelivr.net/npm/jquery@3.7.0/+esm', preload: true
pin 'filepond', to: 'https://cdn.jsdelivr.net/npm/filepond@4.30.4/+esm'
pin 'filepond-plugin-image-preview', to: 'https://cdn.jsdelivr.net/npm/filepond-plugin-image-preview@4.6.11/+esm'
pin 'filepond-plugin-file-validate-type', to: 'https://cdn.jsdelivr.net/npm/filepond-plugin-file-validate-type@1.2.8/+esm'
pin 'qrcode-svg', to: 'https://cdn.jsdelivr.net/npm/filepond@4.30.4/+esm'

pin_all_from 'app/assets/javascript/controllers', under: 'controllers'
