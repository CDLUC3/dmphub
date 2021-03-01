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
        load_json
        headers = auth
        if headers[:Authorization].present?
          expunge_test_records
          # Submit the DMP for creation
          p 'DMP creation attempt:'
          p ''
          create_dmp(headers: headers, payload: @content)
          p @response.code == 201 ? "SUCCESS!" : "FAILURE!"
          pp @response_body.inspect
          p '-------------------------------'
          p ''
          p 'Ensuring we cannot create a duplicate:'
          p ''
          verify_no_duplicates(headers: headers, payload: @content)
          p @response.code == 405 ? "SUCCESS!" : "FAILURE!"
          pp @response_body.inspect
          p '-------------------------------'
          expunge_test_records
        else
          p 'Unable to authenticate with the credentials provided.'
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

  desc 'DEV ENV ONLY! - Will update a DMP - Expects 5 args: host, client name, client_id, client_secret, and file name (from spec/test_cases/)'
  task :update, [:host, :client_name, :client_id, :client_secret, :file_name] => [:environment] do |t, args|
    if args.any? && args[:file_name].present?
      if Rails.env.development?
        @args = args
        @purge_time = "2021-03-01 00:00:00" # Time.now.utc
        load_json
        headers = auth
        if headers[:Authorization].present?
          expunge_test_records
          # Submit the DMP for creation
          p 'DMP creation attempt:'
          p ''
          create_dmp(headers: headers, payload: @content)
          p @response.code == 201 ? "SUCCESS!" : "FAILURE!"
          pp @response_body.inspect

          sleep 2 # Wait a couple of seconds so the modification date will change

          p '-------------------------------'
          p ''
          p 'Ensuring we can update the DMP:'
          p ''
          p @original_dmp = @response_body['items'].first['dmp']
          scramble_content
          update_dmp(headers: headers, payload: @content)
          p @response.code == 200 ? "SUCCESS!" : "FAILURE!"
          p @response_body.inspect

          p 'Verifying update:'
          p '-------------------------------'
          verify_update
          #expunge_test_records
          p '-------------------------------'
          p "DONE. Any errors are reported above."
        else
          p 'Unable to authenticate with the credentials provided.'
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

  # Remove the test DMP
  def expunge_test_records
    DataManagementPlan.where("created_at >= ?", @purge_time).destroy_all
  end

  # Open the file and process the JSON
  def load_json
    file_path = Rails.root.join('spec', 'support', 'test_cases', @args[:file_name])
    if File.exist?(file_path)
      begin
        @content = File.read(file_path)
        @json = JSON.parse(@content)
        p "Invalid JSON format - No { dmp: { :title } } found!" unless @json.fetch('dmp', {})['title'].present?
      rescue JSON::ParserError => e
        p "Unable to Parse the JSON contained in #{file_path} -- #{e.message}"
      end
    else
      p "File does not exist! Make sure you have included the extension. --- #{file_path}"
    end
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

    @response = HTTParty.post(target, opts)
    @response_body = JSON.parse(@response.body)
  end

  # Verify a duplicate cannot be created
  def verify_no_duplicates(headers: default_headers, payload:)
    target = "#{@args[:host]}/api/v0/data_management_plans"
    opts = { headers: headers, body: payload, follow_redirects: true, debug: true }

    @response = HTTParty.post(target, opts)
    @response_body = JSON.parse(@response.body)
  end

  # Update a DMP via the API
  def update_dmp(headers: default_headers, payload:)
    doi = @original_dmp['dmp_id']['identifier'].gsub(/https?:\/\/doi.org\//, '')
    target = "#{@args[:host]}/api/v0/data_management_plans/#{doi}"
    opts = { headers: headers, body: payload, follow_redirects: true, debug: true }

    @response = HTTParty.put(target, opts)
    @response_body = JSON.parse(@response.body)
  end

  def scramble_content
    @updated = @json.clone
    @updated['dmp']['dmp_id'] = @original_dmp['dmp_id']
    @updated['dmp']['title'] = Faker::Lorem.sentence
    @updated['dmp']['description'] = Faker::Lorem.paragraph
    @updated['dmp']['language'] = Api::V0::ConversionService::LANGUAGES.reject { |l| l == @original_dmp['language'] }.sample
    @updated['dmp']['created'] = Time.now.utc.to_formatted_s(:iso8601)
    @updated['dmp']['modified'] = Time.now.utc.to_formatted_s(:iso8601)

    ethics = Api::V0::ConversionService.boolean_to_yes_no_unknown(@updated['dmp']['ethical_issues_exist'])
    @updated['dmp']['ethical_issues_exist'] = %w[yes no unknown].reject { |o| o == ethics }.sample
    @updated['dmp']['ethical_issues_report'] = Faker::Internet.url
    @updated['dmp']['ethical_issues_description'] = Faker::Lorem.paragraph

    @updated['dmp']['contact'] = {
      "name": Faker::Movies::StarWars.character,
      "mbox": Faker::Internet.email
    }
    @content = @updated.to_json
  end

  def verify_update
    dmp = @response_body['items'].first['dmp']
    %w[title, description language created ethical_issues ethical_issues_report
       ethical_issues_description].each do |attr|
      p "    - #{attr.upcase} was not updated!" if unchanged?(@original_dmp, dmp, attr)
      p "    - #{attr.upcase} has the wrong value!" unless matched?(@updated['dmp'], dmp, attr)
    end

    # Verify primary contact change
    if dmp['contact'].present?
      p "    - CONTACT was not overwritten" unless dmp['contact'].length == 1
      %w[name mbox contact_id].each do |attr|
        p "    - CONTACT->#{attr.upcase} was not updated!" if unchanged?(@original_dmp['contact'], dmp['contact'], attr)
        p "    - CONTACT->#{attr.upcase} has the wrong value!" unless matched?(@updated['dmp']['contact'], dmp['contact'], attr)
      end
    else
      p '    - CONTACT was removed instead of replaced!'
    end
  end

  def unchanged?(original, response, attr)
    original[attr] == response[attr] && !response[attr].nil?
  end
  def matched?(expected, response, attr)
    response[attr] == expected[attr]
  end
end
