# rubocop:disable Naming/FileName
# frozen_string_literal: true

server 'localhost', user: 'dmp', roles: %w[web app db]
set :application, ENV['CAPISTRANO_APP']  || 'DMPHub_x2'
set :rails_env,   ENV['RAILS_ENV']       || 'production'
set :repo_url,    ENV['REPO']            || 'https://github.com/cdluc3/dmphub.git'
set :branch,      ENV['BRANCH']          || 'main'
# rubocop:enable Naming/FileName
