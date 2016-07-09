# config valid only for current version of Capistrano
lock '3.5.0'

set :application, 'FasT'
set :repo_url, 'git@github.com:A1bi/FasT.git'
set :deploy_to, "$HOME/apps/FasT/#{fetch(:stage)}"

append :linked_files, 'config/database.yml', 'config/secrets.yml', 'config/application.yml'
append :linked_dirs, 'public/system', 'public/uploads'

set :default_env, { path: "$HOME/.nvm/versions/node/v6.3.0/bin:$PATH" }

set :keep_releases, 3

set :workers, { mailer_queue: 1 }
set :resque_environment_task, true

namespace :deploy do
  after :publishing, :restart do
    on roles(:app) do
      execute "bash -l -c 'service unicorn_#{fetch(:application)}_#{fetch(:stage)} restart'"
    end
  end
end

namespace :rails do
  task :clear_cache do
    on roles(:app) do
      execute 'echo "flush_all" | nc -q 2 localhost 11211'
    end
  end

  task :console do
    on roles(:app), primary: true do |host|
      cmd = "cd #{fetch(:deploy_to)}/current && #{SSHKit.config.command_map[:bundle]} exec rails console #{fetch(:stage)}"
      exec "ssh -l #{host.user} #{host.hostname} -p #{host.port || 22} -t '#{cmd}'"
    end
  end
end

after 'deploy:restart', 'rails:clear_cache'
after 'deploy:restart', 'resque:restart'
