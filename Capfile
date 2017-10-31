require "capistrano/setup"
require "capistrano/deploy"
require 'capistrano/rvm'
require 'capistrano/bundler'
require 'capistrano/console'
require 'capistrano-resque'
require "capistrano/scm/git"
install_plugin Capistrano::SCM::Git

# load .env
require 'dotenv'
Dotenv.load

# Load custom tasks from `lib/capistrano/tasks` if you have any defined
Dir.glob("lib/capistrano/tasks/*.rake").each { |r| import r }
