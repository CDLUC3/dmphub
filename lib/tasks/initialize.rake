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
    if User.all.empty?
      User.create(first_name: 'Super', last_name: 'User', email: 'super.user@example.org',
                  password: 'password_123', role: 'super_user')
    end

    p "The default Super User was created email: `super.user@example.org`, \
       password: `password_123`. You should log in and change both of these \
       values before deploying the application."
  end

  desc 'Create a default client application for API access/testing'
  task default_client_app: :environment do
    client = ApiClient.create(name: 'dmphub', description: 'DMPHub testing account',
                              contact_email: 'your.email@institution.org',
                              client_id: '1234567890', client_secret: '0987654321')
    ApiClientPermission.create(permission: 0, api_client: client)
    ApiClientPermission.create(permission: 1, api_client: client)
    ApiClientPermission.create(permission: 2, api_client: client)

    Provenance.create(name: 'dmphub', description: 'DMPHub testing account')

    p "The default API client was created. You should change the contact_email, \
       client_id and client_secret directly in the DB for security purposes. A \
       corresponding Provenance record was created for the DMPHub account and the
       client was given full permissions."

    p "To test the api, use: `{\"grant_type\":\"client_credentials\",\"client_id\" \
       :\"#{client.client_id}\",\"client_secret\"}` when authenticating."
  end

  desc ' Create the DMPTool application'
  task dmptool_client_app: :environment do
    client = ApiClient.create(name: 'dmproadmap', description: 'DMPRoadmap',
                              contact_email: 'your.email@institution.org',
                              client_id: '8888888', client_secret: '0987654321')
    ApiClientPermission.create(permission: 0, api_client: client)
    ApiClientPermission.create(permission: 1, api_client: client)
    ApiClientPermission.create(permission: 2, api_client: client)

    Provenance.create(name: 'dmproadmap', description: 'DMPRoadmap')

    p "The default DMPRoadmap client was created. You should change the contact_email, \
       client_id and client_secret directly in the DB for security purposes. A \
       corresponding Provenance record was created for the DMPRoadmap account and the
       client was given full permissions."

    p "To test the api, use: `{\"grant_type\":\"client_credentials\",\"client_id\" \
       :\"#{client.client_id}\",\"client_secret\"}` when authenticating."
  end

  desc ' Create the NSF Awards API Scanner application'
  task nsf_client_app: :environment do
    client = ApiClient.create(name: 'national_science_foundation',
                              description: 'NSF awards scanner',
                              contact_email: 'your.email@institution.org',
                              client_id: '9999999', client_secret: '0987654321')
    ApiClientPermission.create(permission: 0, api_client: client)
    ApiClientPermission.create(permission: 1, api_client: client,
                               rules: '{"award_assertion":"SELECT a.* FROM awards a \
                                                           INNER JOIN organizations o ON a.organization_id = o.id \
                                                           INNER JOIN identifiers i ON o.id = i.identifiable_id \
                                                             AND i.identifiable_type = \'Organization\' \
                                                           WHERE i.category = 1 \
                                                           AND i.value = \'http://dx.doi.org/10.13039/100000104\';"}')
    ApiClientPermission.create(permission: 2, api_client: client)

    Provenance.create(name: 'national_science_foundation', description: 'NSF awards scanner')

    p "The NSF awards scanner client was created. You should change the contact_email, \
       client_id and client_secret directly in the DB for security purposes. A \
       corresponding Provenance record was created for the NSF account and the
       client was given full permissions."

    p "To test the api, use: `{\"grant_type\":\"client_credentials\",\"client_id\" \
       :\"#{client.client_id}\",\"client_secret\"}` when authenticating."
  end
end
