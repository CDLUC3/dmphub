# frozen_string_literal: true

require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Dmphub
  # The DMP Hub application
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.0

    # add_autoload_paths_to_load_path is true by default for backwards compatibility, but allows you to
    # opt-out from adding the autoload paths to $LOAD_PATH.
    # This makes sense in most applications, since you never should require a file in app/models, for example,
    # and Zeitwerk only uses absolute file names internally.
    # By opting-out you optimize $LOAD_PATH lookups (less directories to check), and save Bootsnap work and memory
    # consumption, since it does not need to build an index for these directories.
    config.add_autoload_paths_to_load_path

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.
  end
end
