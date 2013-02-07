namespace :nginx do
desc "Setup nginx configuration for this application"
  task :setup, roles: :web do
		conf = "#{shared_path}/config/nginx_conf"
    template "nginx_unicorn.erb", conf
		run "#{sudo} ln -nfs #{conf} /etc/nginx/sites-enabled/#{application}"
    reload
  end
  after "deploy:setup", "nginx:setup"
  
  %w[start stop restart reload].each do |command|
    desc "#{command} nginx"
    task command, roles: :web do
      run "#{sudo} service nginx #{command}"
    end
  end
end