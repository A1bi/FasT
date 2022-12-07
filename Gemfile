# frozen_string_literal: true

source 'https://rubygems.org'

gem 'pg'
gem 'puma', '~> 6.0'
gem 'rails', '~> 7.0.0'
gem 'sidekiq', '~> 7.0'

gem 'apnotic', '~> 1.7.0'
gem 'auto_strip_attributes', '~> 2.6.0'
gem 'bcrypt', '~> 3.1.16'
gem 'bindata', '~> 2.4.3'
gem 'bootsnap', require: false
gem 'config', '~> 4.0'
gem 'dalli', '~> 3.0'
gem 'httparty', '~> 0.18'
gem 'kt-paperclip', '~> 7.0'
gem 'name_of_person'
gem 'phony_rails', '~> 0.15.0'
gem 'pundit', '~> 2.2.0'
gem 'rubyzip', '~> 2.0'
gem 'sentry-rails'
gem 'sentry-ruby'
gem 'sentry-sidekiq'
gem 'sepa_king', '~> 0.14.0'
gem 'simpleidn', '~> 0.2.1'
gem 'whenever', require: false

gem 'corona_presence_tracing'
gem 'icalendar', '~> 2.7'
gem 'jbuilder', '~> 2.10'
gem 'matrix' # needed for prawn
gem 'prawn', '~> 2.4.0'
gem 'prawn-qrcode', '~> 0.5.1'
gem 'prawn-svg', '~> 0.32.0'
gem 'prawn-table', '~> 0.2.1'
gem 'record_tag_helper', '~> 1.0.1'
gem 'roadie', '~> 5.0'
gem 'roadie-rails', '~> 3.0'
gem 'sass-rails', '~> 6.0.0'
gem 'slim'
gem 'sprockets-rails', '~> 3.4'
gem 'webpacker', '~> 5.0'

group :development, :test do
  gem 'byebug'
  gem 'ffaker', '~> 2.13'
  gem 'rspec-rails', '~> 6.0.0.rc1'
end

group :test do
  gem 'factory_bot_rails'
  gem 'pdf-inspector'
  gem 'shoulda-matchers', '~> 5.0'
  gem 'simplecov', require: false
end

group :development, :ci do
  gem 'capistrano', '~> 3.14', require: false
  gem 'capistrano-bundler', '~> 2.0', require: false
  gem 'capistrano-rails', '~> 1.4', require: false
  gem 'rubocop', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-rspec', require: false
end
