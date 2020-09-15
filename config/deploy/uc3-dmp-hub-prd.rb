set :application, 'DMPHub_Stage_x2'
server 'localhost', user: 'dmp', roles: %w[web app db]
set :rails_env, ENV['RAILS_ENV'] || 'production'
set :branch, ENV['BRANCH'] || 'main'
set :repo_url, ENV['REPO'] || 'https://github.com/cdluc3/dmphub.git'
