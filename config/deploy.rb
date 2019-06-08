set :application, 'FasT'
set :repo_url, 'git@gitlab.a0s.de:FasT/FasT.git'
set :deploy_to, '$HOME/FasT'

append :linked_files, 'config/master.key'
append :linked_dirs, 'storage', 'public/system', 'public/uploads', 'tmp/cache'

set :keep_releases, 3

# unicorn
set :unicorn_pid, "#{shared_path}/tmp/pids/unicorn.pid"
set :unicorn_config_path, "#{current_path}/config/unicorn.rb"

namespace :deploy do
  after :published, 'unicorn:restart'
end

namespace :rails do
  task :console do
    on roles(:app), primary: true do |host|
      cmd = "cd #{fetch(:deploy_to)}/current && #{SSHKit.config.command_map[:bundle]} exec rails c -e #{fetch(:stage)}"
      exec "ssh -l #{host.user} #{host.hostname} -p #{host.port || 22} -t '#{cmd}'"
    end
  end
end
