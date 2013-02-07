require "bundler/capistrano"

load "config/recipes/base"
load "config/recipes/nginx"
load "config/recipes/unicorn"
load "config/recipes/mysql"

server "85.214.76.70", :web, :app, :db, primary: true

set :user, "deployer"
set :application, "FasT"
set :github_user, "A1bi"
set :server_name, "theater-kaisersesch.de www.theater-kaisersesch.de"
set :deploy_to, "/home/#{user}/apps/#{application}"
set :deploy_via, :remote_cache
set :use_sudo, false

set :scm, "git"
set :repository, "git@github.com:#{github_user}/#{application}.git"
set :branch, "master"

default_run_options[:pty] = true
ssh_options[:forward_agent] = true

after "deploy", "deploy:cleanup" # keep only the last 5 releases