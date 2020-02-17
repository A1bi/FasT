source 'https://rubygems.org'

gem 'rails', '~> 6.0.0'

gem 'pg'

gem 'pundit', '~> 2.1.0'

gem 'sass-rails', '~> 6.0.0'
gem 'sprockets-rails', '~> 3.2.0'

gem 'uglifier'

gem 'jquery-rails', '~> 4.3.1'
gem 'jquery-ui-rails', '~> 6.0.0'

gem 'paperclip', '~> 6.1.0'

gem 'bcrypt', '~> 3.1.13'

gem 'icalendar', '~> 2.6.1'

gem 'prawn', '~> 2.2.2'
gem 'prawn-qrcode', '~> 0.5.1'
gem 'prawn-svg', '~> 0.30.0'
gem 'prawn-table', '~> 0.2.1'

gem 'rubyzip', '~> 2.0.0'

gem 'roadie', '~> 3.5.0'
gem 'roadie-rails', '~> 2.1.0'

gem 'sepa_king', '~> 0.12.0'

gem 'dalli', '~> 2.7.8'

gem 'sidekiq', '~> 5.2.2'

gem 'auto_strip_attributes', '~> 2.5.0'

gem 'phony_rails', '~> 0.14.2'

gem 'record_tag_helper', '~> 1.0.1'

gem 'sentry-raven', '~> 2.13.0'

gem 'bootsnap', require: false

gem 'listen', '~> 3.0'

gem 'config', '~> 2.0.0'

gem 'bindata', '~> 2.4.3'

gem 'apnotic', '~> 1.5.0'
gem 'connection_pool', '~> 2.2.2'

gem 'simpleidn', '~> 0.1.1'

gem 'name_of_person'

gem 'request_store', '~> 1.5.0'

gem 'jbuilder', '~> 2.9.0'

gem 'unicorn', '~> 5.5.0'

gem 'httparty', '~> 0.17.3'

group :development do
  gem 'byebug'
  gem 'capistrano', '~> 3.11.0'
  gem 'capistrano-bundler', '~> 1.6.0', require: false
  gem 'capistrano-rails', '~> 1.4.0', require: false
  gem 'ffaker', '~> 2.13.0'
  gem 'rubocop', '~> 0.74.0'
  gem 'rubocop-rails', '~> 2.3.0'
  gem 'spring', '~> 2.1.0'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

group :test do
  require 'rbconfig'
  if RbConfig::CONFIG['target_os'] =~ /(?i-mx:bsd|dragonfly)/
    gem 'rb-kqueue', '>= 0.2'
  end
end

source 'https://rails-assets.org' do
  gem 'rails-assets-chartjs', '~> 1.0.2'
  gem 'rails-assets-ol3-bower', '~> 3.18.2'
  gem 'rails-assets-raven-js', '~> 3.27.0'
  gem 'rails-assets-socket.io-client', '~> 2.1.0'
  gem 'rails-assets-validator-js', '~> 1.3.0'
end
