# frozen_string_literal: true

require 'httparty'

namespace :api_tester do
  desc 'Verifies that the specified host\'s API is functional. Expects 4 args: host, client name, client_id and client_secret'
  task :verify, [:host, :client_name, :client_id, :client_secret] => [:environment] do |t, args|
    if args.any? && args[:client_secret].present?
      @args = args
      headers = auth

      if headers[:Authorization].present?
        # Retrieve the list of DMPs
        pp retrieve_dmps(headers: headers).inspect
      end
    else
      p 'Missing essential information. This script requires 4 arguments. The host (e.g. https://my.org.edu), your client name, client_id and the client_secret.'
      p 'Please retry with: `rails "api_tester:verify[http://localhost:3001,dmptool,12345,abcdefg]"`'
      p 'Note the position of the quotes!'
    end
  end

  desc 'DEV ENV ONLY! - Will create a DMP - Expects 5 args: host, client name, client_id, client_secret, and file name (from spec/test_cases/)'
  task :create, [:host, :client_name, :client_id, :client_secret, :file_name] => [:environment] do |t, args|
    if args.any? && args[:file_name].present?
      if Rails.env.development?
        @args = args
        file_path = Rails.root.join('spec', 'support', 'test_cases', @args[:file_name])
        if File.exist?(file_path)
          begin
            content = File.read(file_path)
            json = JSON.parse(content)
          rescue JSON::ParserError => e
            p "Unable to Parse the JSON contained in #{file_path} -- #{e.message}"
          end

          if json.fetch('dmp', {})['title'].present?
            headers = auth
            if headers[:Authorization].present?
              # Remove the test DMP if it already exists
              DataManagementPlan.where(title: json['dmp']['title']).destroy_all

              # Submit the DMP for creation
              pp create_dmp(headers: headers, payload: content).inspect
            else
              p 'Unable to authenticate with the credentials provided.'
            end
          end
        else
          p "File does not exist! Make sure you have included the extension. --- #{file_path}"
        end
      else
        p 'You cannot run this task in a non-development environment. It modifies the database!'
      end
    else
      p 'Missing essential information. This script requires 5 arguments. The host (e.g. https://my.org.edu), your client name, client_id, client_secret and the file name.'
      p 'Please retry with: `rails "api_tester:verify[http://localhost:3001,dmptool,12345,abcdefg,minimum_dmp.json]"`'
      p 'Note the position of the quotes!'
    end
  end

  private

  def default_headers
    {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Server-Agent': "#{@args[:client_name]} (#{@args[:client_id]})"
    }
  end

  # Authenticate via the API
  def auth(headers: default_headers)
    payload = {
      grant_type: 'client_credentials',
      client_id: @args[:client_id],
      client_secret: @args[:client_secret]
    }
    target = "#{@args[:host]}/api/v0/authenticate"
    resp = HTTParty.post(target, body: payload.to_json, headers: headers, debug: true)
    response = JSON.parse(resp.body)

    p "Unable to authenticate: #{resp.code} - #{response.inspect}" unless resp.code == 200
    return nil unless resp.code == 200

    token = response
    headers.merge({ 'Authorization': "#{token['token_type']} #{token['access_token']}" })
  end

  # Fetch the list of DMPs via the API
  def retrieve_dmps(headers: default_headers, page: 1)
    target = "#{@args[:host]}/api/v0/data_management_plans?page=#{page}"
    p 'DMP list attempt:'
    p "    Target: #{target}"
    p "    Headers: #{headers}"
    p '-----------------------'
    p

    resp = HTTParty.get(target, headers: headers, debug: true)
    p "Unable to get DMPs: #{resp.code} - #{resp.body}" unless resp.code == 200
    resp.code == 200 ? JSON.parse(resp.body) : nil
  end

  # Create a DMP via the API
  def create_dmp(headers: default_headers, payload:)
    target = "#{@args[:host]}/api/v0/data_management_plans"
    opts = { headers: headers, body: payload, follow_redirects: true, debug: true }

    p 'DMP creation attempt:'
    p "    Target: #{target}"
    p "    Headers: #{headers}"
    p '-----------------------'
    p

    resp = HTTParty.post(target, opts)
    dmp = JSON.parse(resp.body)
    # If it failed just return with the error response
    p "Unable to create the DMP: #{resp.code}" unless resp.code == 201
    return dmp unless resp.code == 201

    p 'Ensuring we cannot create a duplicate:'
    p '-----------------------'
    resp = HTTParty.post(target, opts)
    p "Fail - Was able to create a duplicate DMP: #{resp.code}" if resp.code == 201
    p 'Success - could not create a duplicate DMP.' if resp.code == 405
    resp.code != 405 ? JSON.parse(resp.body) : dmp
  end
end
