require 'securerandom'

namespace :rails do
  desc "Open the rails console on one of the remote servers"
  task :console, :roles => :app do
    hostname = find_servers_for_task(current_task).first
    exec "ssh -l #{user} #{hostname} -t 'source ~/.profile && cd #{current_path} && ./script/rails c #{rails_env}'"
  end
  
  desc "Copy the default config file and set the secret token for cookies"
  task :update_config_file, roles: :app do
    path = "#{shared_path}/config/secret_token"
    token = nil
    if capture("if [ -e '#{path}' ]; then echo -n 'true'; fi") == "true"
      token = capture("cat #{path}")
    else
      token = SecureRandom.hex(64)
      put token, path
    end
    config = YAML.load_file(File.expand_path("../../application.defaults.yml", __FILE__))
    config['production']['secret_token'] = token
    put config.to_yaml, "#{current_path}/config/application.yml"
  end
  after "deploy:finalize_update", "rails:update_config_file"
end