source 'https://rubygems.org'

gem 'rails', '~> 5.0.2'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

# Gems used only for assets and not required
# in production environments by default.

gem 'sprockets-rails',    '~> 3.1.0'
gem 'sass-rails',   '~> 5.0.5'
#gem 'coffee-rails', '~> 3.2.1'

# See https://github.com/sstephenson/execjs#readme for more supported runtimes
gem 'therubyracer', platforms: :ruby

gem 'uglifier'

gem 'jquery-rails', '~> 4.1.1'
gem 'jquery-ui-rails', '~> 5.0.5'

gem 'paperclip', '~> 5.0.0'

gem 'bcrypt-ruby', '~> 3.1.5'

gem 'icalendar', '~> 2.4.0'

gem 'prawn', '~> 2.1.0'
gem 'prawn-table', '~> 0.2.1'
gem 'prawn-svg', '~> 0.25.1'
gem 'prawn-qrcode', '~> 0.2.2'

gem 'rubyzip', '~> 1.2.0'

gem 'roadie', '~> 3.1.1'
gem 'roadie-rails', '~> 1.1.1'

gem 'sepa_king', '~> 0.8.0'

gem 'dalli', '~> 2.7.6'

gem 'ar_after_transaction', '~> 0.4.0'

gem 'resque', '~> 1.26.0'

gem 'groupdate', '~> 3.0.0'

gem 'auto_strip_attributes', '~> 2.0'

gem 'phony_rails', '~> 0.14.2'

gem 'record_tag_helper', '~> 1.0'

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

# Use unicorn as the app server
gem 'unicorn', '~> 5.1.0'

group :development do
  gem 'capistrano', '~> 3.6.0'
  gem 'capistrano-rvm', '~> 0.1.1', require: false
  gem 'capistrano-bundler', '~> 1.1.3', require: false
  gem 'capistrano-rails', '~> 1.1.7', require: false
  gem 'capistrano3-unicorn', require: false
  gem 'capistrano-resque', '~> 0.2.2', require: false
  gem 'sqlite3', '~> 1.3.11'
  gem 'ffaker', '~> 2.2.0'
end

group :staging, :production do
  gem 'mysql2', '~> 0.4.4'
end

# To use debugger
# gem 'debugger'

source 'https://rails-assets.org' do
  gem 'rails-assets-chartjs', '~> 1.0.2'
  gem 'rails-assets-jReject', '~> 1.1.4'
  gem 'rails-assets-validator-js', '~> 1.3.0'
  gem 'rails-assets-socket.io-client', '~> 1.4.6'
  gem 'rails-assets-spinjs', '~> 2.1.0'
  gem 'rails-assets-ol3-bower', '~> 3.17.1'
end
