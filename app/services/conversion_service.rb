# frozen_string_literal: true

# Provides conversion methods for JSON <--> Model
class ConversionService

  class << self
    # Converts a boolean field to [yes, no, unknown]
    def boolean_to_yes_no_unknown(value)
      value == true ? 'yes' : (value == false ? 'no' : 'unknown')
    end

    # Converts a [yes, no, unknown] field to boolean (or nil)
    def yes_no_unknown_to_boolean(value)
      value == 'yes' ? true : (value.blank? || value == 'unknown' ? nil : false)
    end
  end

end
