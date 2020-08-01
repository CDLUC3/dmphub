set :application, 'DMPHub_Stage_x2'
#server 'uc3-dmphub02x2-stg.cdlib.org', user: 'dmp', roles: %w[web app db]
server 'localhost', user: 'dmp', roles: %w[web app db]
set :rails_env, 'stage'
set :repo_url, 'https://github.com/ashleygould/dmphub.git'
set :branch, 'puppet_integration'
set :revision, '0.0.0dev9'
