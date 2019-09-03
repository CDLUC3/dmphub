require 'set'
namespace :initialize do

  desc "Seed database tables"
  task all: :environment do
    Rake::Task['initialize:super_user'].execute
    Rake::Task["initialize:default_client_app"].execute
  end

  desc "Create the default Super User if no users exist. (Be sure to change the password!)"
  task super_user: :environment do
    return if User.all.any?
    User.create(first_name: 'Super', last_name: 'User', email: 'brian.riley@ucop.edu', password: 'super_user')
  end

  desc "Create a default client application for API access/testing"
  task default_client_app: :environment do
    Doorkeeper::Application.create(name: 'default_app', redirect_uri: 'urn:ietf:wg:oauth:2.0:oob')
  end

end