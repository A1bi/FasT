namespace :one_off do
  task :run do
    on roles(:app), primary: true do
      within current_path do
        with rails_env: fetch(:rails_env) do
          execute :bundle, 'exec rake one_off:run'
        end
      end
    end
  end
end
