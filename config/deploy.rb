set :assets_roles, [:app]
set :application, "hound-liners"
set :repo_url, "git@github.com:Rademade/linters.git"
set :branch, "dev"
set :deploy_to, "/home/hound/linters-app"
set :linked_dirs, %w(log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system)
set :keep_releases, 5

set :rvm_ruby_version, '2.4.1'