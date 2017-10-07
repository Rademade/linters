set :user, "hound"
server "vm.rademade.com",
  user: fetch(:user),
  port: 2230, roles: %w{app resque_worker resque_scheduler}


set :workers, {
  "linters" => 3,
  "eslint_review" => 1,
  "jshint_review" => 1,
  "rubocop_review" => 5,
  "coffeelint_review" => 1,
  "tslint_review" => 1,
  "reek_review" => 1
}

set :resque_log_file, "log/resque.log"