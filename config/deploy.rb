set :application, 'FasT'
set :repo_url, 'git@gitlab.a0s.de:FasT/FasT.git'
set :deploy_to, '~/FasT'

append :linked_files, 'config/master.key'
append :linked_dirs, 'storage', 'public/system', 'public/uploads', 'tmp/cache'

set :keep_releases, 3

set :unicorn_pid, "#{shared_path}/tmp/pids/unicorn.pid"
set :unicorn_config_path, "#{current_path}/config/unicorn.rb"
set :unicorn_service_name, 'fast_web'

set :sidekiq_service_name, 'fast_worker'
