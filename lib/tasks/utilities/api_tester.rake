# frozen_string_literal: true

require 'httparty'

namespace :api_tester do
  desc 'Verifies that the specified host\'s API is functional. Expects 4 args: host, client name, client_id and client_secret'
  task :verify, %i[host client_name client_id client_secret] => [:environment] do |_t, args|
    if args.any? && args[:client_secret].present?
      @args = args
      headers = auth

      if headers[:Authorization].present?
        # Retrieve the list of DMPs
        pp retrieve_dmps(headers: headers).inspect
      end
    else
      # rubocop:disable Layout/LineLength
      p 'Missing essential information. This script requires 4 arguments. The host (e.g. https://my.org.edu), your client name, client_id and the client_secret.'
      # rubocop:enable Layout/LineLength
      p 'Please retry with: `rails "api_tester:verify[http://localhost:3001,dmptool,12345,abcdefg]"`'
      p 'Note the position of the quotes!'
    end
  end

  private

  def default_headers
    {
      'Content-Type': 'application/json',
      Accept: 'application/json',
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
    headers.merge({ Authorization: "#{token['token_type']} #{token['access_token']}" })
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
end
