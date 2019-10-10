# frozen_string_literal: true

require 'set'
namespace :initialize do
  desc 'Seed database tables'
  task all: :environment do
    Rake::Task['initialize:super_user'].execute
    Rake::Task['initialize:default_client_app'].execute
  end

  desc 'Create the default Super User if no users exist. (Be sure to change the password!)'
  task super_user: :environment do
    return if User.all.any?

    User.create(first_name: 'Super', last_name: 'User', email: 'super.user@example.org', password: 'password_123', role: 'super_user')
  end

  desc 'Create a default client application for API access/testing'
  task default_client_app: :environment do
    Doorkeeper::Application.create(name: ConversionService.local_provenance,
                                   redirect_uri: 'urn:ietf:wg:oauth:2.0:oob')
  end

  desc ' Create the default apps for the DMPTool and the NSF Awards API Scanner'
  task dmptool_nsf_client_apps: :environment do
    Doorkeeper::Application.create(name: 'dmptool',
                                   redirect_uri: 'urn:ietf:wg:oauth:2.0:oob')
    Doorkeeper::Application.create(name: 'national_science_foundation',
                                   redirect_uri: 'urn:ietf:wg:oauth:2.0:oob')
  end

  desc 'Fill in the funder name for any awards with a funder_uri but no name'
  task funder_names_from_fundref: :environment do
    Award.where(funder_name: nil).pluck(:funder_uri).uniq.each do |uri|
      name = FundrefService.find_by_uri(uri: uri)
      next unless name.present?

      Award.where(funder_uri: uri).update_all(funder_name: name)
    end
  end
end
