# frozen_string_literal: true

set :application, 'FasT'
set :repo_url, 'git@gitlab.a0s.de:FasT/FasT.git'
set :branch, 'production'
set :deploy_to, '~/FasT'

append :linked_files, 'config/master.key'
append :linked_dirs, 'storage', 'public/system', 'public/uploads', 'tmp/cache',
       'log', 'tmp/cache', '.bundle', 'node_modules'

set :keep_releases, 3

set :bundle_without, 'development test ci'

set :unicorn_service_name, 'fast_web'
set :sidekiq_service_name, 'fast_worker'
