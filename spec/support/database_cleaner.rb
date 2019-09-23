# frozen_string_literal: true

require 'database_cleaner'

RSpec.configure do |config|

  DatabaseCleaner.strategy = :truncation

  DatabaseCleaner.clean

  config.before(:suite) do
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.clean_with(:truncation, except: %w[ar_internal_metadata])
  end

  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end
end
