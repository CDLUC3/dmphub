# frozen_string_literal: true

module Uc3Ssm
  # UC3 SSM initializer that retrives credentials from the SSM store and makes
  # them available to your Rails application
  class Application < Rails::Application
    # Instantiate the Uc3Ssm::ConfigResolver if this is not the dev/test env
    if Rails.env.test? || Rails.env.development?
      Rails.logger.info "Skipping UC3 SSM credential load for the #{Rails.env} environment."
    else
      Rails.logger.info 'Retriving UC3 SSM credentials'

      # The UC3 SSSM gem expects your server to have the following env variables
      # defined and works in conjunction with puppet and the shell script here:
      #    https://github.com/CDLUC3/uc3-aws-cli/blob/main/.profile.d/uc3-aws-util.sh
      #
      # If you do not have these ENV variables set, then you may pass the appropriate
      # values into the ConfigResolver initializer as follows:
      #    ENV['REGION']          can be passed as: `region: 'us-west-2'`
      #    ENV['SSM_ROOT_PATH']   can be passed as: `ssm_root_path: '/program/role/service/env/'`
      #
      # You can also pass in the following:
      #    A Logger    e.g. `logger: Rails.logger` - default is STDOUT
      #
      # For example:
      #   ssm_env = Rails.env.stage? ? 'stg' : 'prd'
      #   ssm_root_path = "/uc3/dmp/hub/#{ssm_env}/"
      #   resolver = Uc3Ssm::ConfigResolver.new(logger: Rails.logger, ssm_root_path: ssm_root_path)

      # You can also pass the region to the initializer, e.g. `region: 'us-west-2'`

      resolver = Uc3Ssm::ConfigResolver.new(logger: Rails.logger)

      # Map the SSM values to your config here. You can use the `resolver.parameter_for_key`
      # or `resolver.parameters_for_path` methods to access your values.
      #
      # Each of these methods will build off of your defined ENV['SSM_ROOT_PATH'] or
      # the :ssm_root_path you specified in the call to `Uc3Ssm::ConfigResolver.new`
      # So for example if your SSM_ROOT_PATH is `/uc3/role/service/env/` then
      # you would just pass `my_key` or `my/path/` to these methods.
      #
      # For retrieving a specific configuration variable:
      #   Rails.configuration.x.my_key = resolver.parameter_for_key("my_key")
      #
      # For retrieving all key+values in the specified path
      # For available `options` you can pass to this method, see:
      # https://docs.aws.amazon.com/sdk-for-ruby/v2/api/Aws/SSM/Client.html:
      #   resp = resolver.parameters_for_path(recursive: true)
      #   resp.each { |param| Rails.configuration.x[:"#{param.name.upcase}"] = param.value } if resp.is_a?(Array)

      p "MASTER KEY: #{resolver.parameter_for_key('master_key')}"

    end
  rescue Uc3Ssm::ConfigResolverError => e
    Rails.logger.error e.message
  end
end
