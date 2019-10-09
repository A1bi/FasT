namespace :deploy do
  after :published, 'unicorn:reload'
end

namespace :unicorn do
  %i[reload restart].each do |command|
    task command do
      on roles(:app) do
        sudo :service, fetch(:unicorn_service_name), command
      end
    end
  end
end
