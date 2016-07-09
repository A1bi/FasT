rails_env = ENV['RAILS_ENV']
app_path = "#{ENV['HOME']}/apps/FasT/#{rails_env}"
current_path = "#{app_path}/current"
shared_path = "#{app_path}/shared"

working_directory current_path
pid "#{shared_path}/tmp/pids/unicorn.pid"

listen "/tmp/unicorn.FasT.#{rails_env}.sock", backlog: 64
worker_processes 3
timeout 45

# logging
stderr_path "#{shared_path}/log/unicorn.log"
stdout_path "#{shared_path}/log/unicorn.log"

# use correct Gemfile on restarts
before_exec do |server|
  ENV['BUNDLE_GEMFILE'] = "#{current_path}/Gemfile"
end

preload_app true

before_fork do |server, worker|
  # the following is highly recomended for Rails + "preload_app true"
  # as there's no need for the master process to hold a connection
  if defined?(ActiveRecord::Base)
    ActiveRecord::Base.connection.disconnect!
  end

  # Before forking, kill the master process that belongs to the .oldbin PID.
  # This enables 0 downtime deploys.
  old_pid = "#{server.config[:pid]}.oldbin"
  if File.exists?(old_pid) && server.pid != old_pid
    begin
      Process.kill('QUIT', File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
      # someone else did our job for us
    end
  end
end

after_fork do |server, worker|
  if defined?(ActiveRecord::Base)
    ActiveRecord::Base.establish_connection
  end

  Rails.cache.clear if defined? Rails.cache
end