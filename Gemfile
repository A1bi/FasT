# frozen_string_literal: true

source 'https://rubygems.org'

gem 'pg'
gem 'puma', '~> 6.0'
gem 'rails', '~> 8.0.0'
gem 'redis', '~> 5.0'
gem 'sidekiq', '~> 8.0'

gem 'apnotic', '~> 1.7.0'
gem 'auto_strip_attributes', '~> 2.6.0'
gem 'bcrypt', '~> 3.1.16'
gem 'bindata', '~> 2.5.0'
gem 'bootsnap', require: false
gem 'cmxl'
gem 'config', '~> 5.0'
gem 'dalli', '~> 3.0'
gem 'doorkeeper', '~> 5.6'
gem 'dry-validation'
gem 'epics', '~> 2.10.0'
gem 'httparty', '~> 0.18'
gem 'importmap-rails', '~> 1.2'
gem 'kt-paperclip', '~> 7.0'
gem 'name_of_person'
gem 'phony_rails', '~> 0.15.0'
gem 'pundit', '~> 2.5.0'
gem 'rubyzip', '~> 2.0'
gem 'sentry-rails'
gem 'sentry-ruby'
gem 'sentry-sidekiq'
gem 'sepa_king', '~> 0.14.0'
gem 'simpleidn', '~> 0.2.1'
gem 'stimulus-rails', '~> 1.2'
gem 'webauthn', '~> 3.2'
gem 'web-push', '~> 3.0'
gem 'whenever', require: false

gem 'jbuilder', '~> 2.10'
gem 'matrix' # needed for prawn
gem 'prawn-qrcode', '~> 0.5.1'
gem 'prawn-svg', '~> 0.37.0'
gem 'prawn-table', '~> 0.2.1'
gem 'record_tag_helper', '~> 1.0.1'
gem 'roadie-rails', '~> 3.0'
gem 'sass-rails', '~> 6.0.0'
gem 'slim'
gem 'sprockets-rails', '~> 3.4'

# lock these versions to fix issues with ttfunk 1.8.0
gem 'prawn', '~> 2.4.0'
gem 'ttfunk', '~> 1.7.0'

group :development, :test do
  gem 'byebug'
  gem 'ffaker', '~> 2.13'
  gem 'rspec-rails', '~> 8.0'
end

group :test do
  gem 'factory_bot_rails', '~> 6.4'
  gem 'pdf-inspector'
  gem 'shoulda-matchers', '~> 6.0'
  gem 'simplecov', require: false
  gem 'webmock', '~> 3.0', require: false
end

group :development, :ci do
  gem 'capistrano', '~> 3.14', require: false
  gem 'capistrano-bundler', '~> 2.0', require: false
  gem 'capistrano-rails', '~> 1.4', require: false
  gem 'rubocop', require: false
  gem 'rubocop-factory_bot', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-rspec', require: false
  gem 'rubocop-rspec_rails', require: false
end
