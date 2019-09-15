namespace :rails do
  task :console do
    on roles(:app), primary: true do |host|
      exec "ssh -l #{host.user} #{host.hostname} -p #{host.port || 22} -t "\
           "'cd #{fetch(:deploy_to)}/current && "\
           "bundle exec rails c -e #{fetch(:stage)}'"
    end
  end
end
