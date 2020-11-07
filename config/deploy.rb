# frozen_string_literal: true

set :application, 'FasT'
set :repo_url, 'git@gitlab.a0s.de:FasT/FasT.git'
set :branch, 'production'
set :deploy_to, '/home/rails/FasT'

append :linked_files, 'config/master.key', 'config/settings.local.yml',
       'config/puma.rb'
append :linked_dirs, 'public/system', 'public/uploads', 'tmp/cache', 'log',
       '.bundle', 'node_modules'

set :keep_releases, 3

set :bundle_without, 'development:test:ci'

set :puma_service_name, 'fast_web'
set :sidekiq_service_name, 'fast_worker'
