source 'https://rubygems.org'

gem 'rails', '~> 5.2.2'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

# Gems used only for assets and not required
# in production environments by default.

gem 'sprockets-rails',    '~> 3.2.0'
gem 'sass-rails',   '~> 5.0.5'
#gem 'coffee-rails', '~> 3.2.1'

# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'mini_racer', platforms: :ruby

gem 'uglifier'

gem 'jquery-rails', '~> 4.3.1'
gem 'jquery-ui-rails', '~> 6.0.0'

gem 'paperclip', '~> 6.1.0'

# unreleased FreeBSD fix
gem 'bcrypt', git: 'git@gitea.dyn.a0s.de:Albrecht/bcrypt-ruby.git', ref: '7644e36'

gem 'icalendar', '~> 2.5.0'

gem 'prawn', '~> 2.2.2'
gem 'prawn-table', '~> 0.2.1'
gem 'prawn-svg', '~> 0.29.0'
gem 'prawn-qrcode', '~> 0.3.0'

gem 'rubyzip', '~> 1.2.0'

gem 'roadie', '~> 3.4.0'
gem 'roadie-rails', '~> 2.0.0'

gem 'sepa_king', '~> 0.11.0'

gem 'dalli', '~> 2.7.8'

gem 'sidekiq', '~> 5.2.2'

gem 'groupdate', '~> 4.1.0'

gem 'auto_strip_attributes', '~> 2.0'

gem 'phony_rails', '~> 0.14.2'

gem 'record_tag_helper', '~> 1.0'

gem 'sentry-raven'

gem 'bootsnap', require: false

gem 'listen', '~> 3.0'

gem 'config'

gem 'bindata', '~> 2.4.3'

gem 'apnotic', '~> 1.5.0'
gem 'connection_pool', '~> 2.2.2'

gem 'simpleidn', '~> 0.1.1'

gem 'name_of_person'

gem 'request_store', '~> 1.2.0'

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
gem 'jbuilder'

# Use unicorn as the app server
gem 'unicorn', '~> 5.5.0'

group :development do
  gem 'capistrano', '~> 3.11.0'
  gem 'capistrano-rvm', '~> 0.1.1', require: false
  gem 'capistrano-bundler', '~> 1.5.0', require: false
  gem 'capistrano-rails', '~> 1.4.0', require: false
  gem 'capistrano3-unicorn', require: false
  gem 'capistrano-sidekiq', '~> 1.0.2', require: false
  gem 'sqlite3', '~> 1.3.0'
  gem 'ffaker', '~> 2.10.0'
  gem 'spring', '~> 2.0.0'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'byebug'
end

group :staging, :production do
  gem 'mysql2', '~> 0.5.1'
end

# To use debugger
# gem 'debugger'

source 'https://rails-assets.org' do
  gem 'rails-assets-chartjs', '~> 1.0.2'
  gem 'rails-assets-validator-js', '~> 1.3.0'
  gem 'rails-assets-socket.io-client', '~> 2.1.0'
  gem 'rails-assets-spinjs', '~> 2.1.0'
  gem 'rails-assets-ol3-bower', '~> 3.18.2'
  gem 'rails-assets-raven-js'
end
