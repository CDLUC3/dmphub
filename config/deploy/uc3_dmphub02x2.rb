set :application, 'DMPHub_Stage_x2'
server 'uc3-dmphub02x2-stg.cdlib.org', user: 'dmp', roles: %w[web app db]
set :rails_env, 'stage'
