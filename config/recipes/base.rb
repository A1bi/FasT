def template(from, to)
	erb = File.read(File.expand_path("../templates/#{from}", __FILE__))
	put ERB.new(erb).result(binding), to
end

def set_default(name, *args, &block)
  set(name, *args, &block) unless exists?(name)
end

namespace :deploy do
  task :install do
		%w[config uploads].each do |dir|
    	run "mkdir -p #{shared_path}/#{dir}"
		end
  end
	
  desc "Symlink the uploads folder"
  task :symlink_uploads, roles: :app do
    run "ln -nfs #{shared_path}/uploads #{release_path}/public/uploads"
  end
  after "deploy:finalize_update", "deploy:symlink_uploads"
end