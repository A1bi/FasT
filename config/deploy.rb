set :application, 'FasT'
set :repo_url, 'git@github.com:A1bi/FasT.git'
set :deploy_to, "$HOME/apps/FasT/#{fetch(:stage)}"

append :linked_files, 'config/database.yml', 'config/secrets.yml', 'config/application.yml'
append :linked_dirs, 'public/system', 'public/uploads'

set :keep_releases, 3

# unicorn
set :unicorn_pid, "#{shared_path}/tmp/pids/unicorn.pid"
set :unicorn_config_path, "#{current_path}/config/unicorn.rb"

# resque
set :workers, { mailer_queue: 1 }
set :resque_environment_task, true

namespace :deploy do
  after :publishing, :restart do
    invoke 'unicorn:restart'
    invoke 'resque:restart'
  end
end

namespace :rails do
  task :console do
    on roles(:app), primary: true do |host|
      cmd = "cd #{fetch(:deploy_to)}/current && #{SSHKit.config.command_map[:bundle]} exec rails console #{fetch(:stage)}"
      exec "ssh -l #{host.user} #{host.hostname} -p #{host.port || 22} -t '#{cmd}'"
    end
  end
end
