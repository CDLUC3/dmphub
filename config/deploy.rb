# frozen_string_literal: true

# config valid for current version and patch releases of Capistrano
lock '~> 3.14.1'

set :rails_env, ENV['RAILS_ENV']

# The Capistrano directory e.g. /dmp/apps/dmphub/
set :capistrano_dir, ENV['CAPISTRANO_DIR']

# GitHub repository - default branch is :main
set :repo_url, 'https://github.com/CDLUC3/dmphub.git'
ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
set :deploy_to, fetch(:capistrano_dir)

# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: "log/capistrano.log", color: :auto, truncate: :auto

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
append :linked_files, 'config/master.key'

# Default value for linked_dirs is []
append :linked_dirs, 'log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'public/system'

# Default value for default_env is {}
set :default_env, { path: '/dmp/local/bin:$PATH' }

# Default value for local_user is ENV['USER']
# set :local_user, -> { `git config user.name`.chomp }

# Default value for keep_releases is 5
# set :keep_releases, 5

# Uncomment the following to require manually verifying the host key before first deploy.
# set :ssh_options, verify_host_key: :secure

# Puma Config
# set :puma_user, 'dmp'
# set :puma_daemonize, true

set :puma_pid, "#{fetch(:capistrano_dir)}/shared/tmp/pids/server.pid"

after :deploy, 'puma:stop'
after :deploy, 'puma:start'

namespace :puma do
  desc 'Start Puma'
  task :start do
    on roles(:app), wait: 1 do
      execute "cd #{release_path} && bundle exec puma -d -e #{fetch(:rails_env)}"
    end
  end

  desc 'Stop Puma'
  task :stop do
    on roles(:app), wait: 1 do
      execute "[ -f #{fetch(:puma_pid)} ] && kill $(cat #{fetch(:puma_pid)}) && rm #{fetch(:puma_pid)} || echo 'Puma is not running'"
    end
  end
end
