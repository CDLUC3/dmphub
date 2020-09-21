# frozen_string_literal: true

require 'uc3-ssm'

# config valid for current version and patch releases of Capistrano
lock '~> 3.14.1'

set :rails_env, ENV['RAILS_ENV']

# The Capistrano directory e.g. /dmp/apps/dmphub/
set :capistrano_dir, ENV['CAPISTRANO_DIR']

# Default branch is :main
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

# Default value for linked_dirs is []
append :linked_dirs, 'log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'public/system'

# Default value for default_env is {}
set :default_env, { path: '$PATH' }

# Default value for local_user is ENV['USER']
# set :local_user, -> { `git config user.name`.chomp }

# Default value for keep_releases is 5
# set :keep_releases, 5

# Uncomment the following to require manually verifying the host key before first deploy.
# set :ssh_options, verify_host_key: :secure

namespace :deploy do
  before :compile_assets, :env_setup

  desc 'Setup ENV Variables'
  task :env_setup do
    on roles(:app), wait: 1 do
      ssm = Uc3Ssm::ConfigResolver.new
      master_key = ssm.parameter_for_key('master_key')
      # TODO: Switch this to ENV['RAILS_MASTER_KEY']
      f = File.open("#{release_path}/config/credentials/#{fetch(:rails_env)}.key", 'w')
      f.puts master_key
      f.close
    end
  end

end
