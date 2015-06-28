require "bundler/capistrano"
require "rvm/capistrano"
require "capistrano-resque"

load "config/recipes/base"
load "config/recipes/nginx"
load "config/recipes/unicorn"
load "config/recipes/mysql"
load "config/recipes/memcached"
load "config/recipes/rails"

server "213.239.219.83", :web, :app, :db, :resque_worker, :resque_scheduler, primary: true

set :user, "deployer"
set :application, "FasT"
set :github_user, "A1bi"
set :domain_name, "theater-kaisersesch.de"
set :deploy_to, "/home/#{user}/apps/#{application}"
set :deploy_via, :remote_cache
set :use_sudo, false

set :scm, "git"
set :repository, "git@github.com:#{github_user}/#{application}.git"
set :branch, "master"

default_run_options[:pty] = true
ssh_options[:forward_agent] = true

after "deploy", "deploy:cleanup" # keep only the last 5 releases

set :workers, { "mailer_queue" => 1 }
set :resque_environment_task, true

after "deploy:restart", "resque:restart"