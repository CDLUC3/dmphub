# frozen_string_literal: true

# Email Validation
class EmailValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    regex = /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
    msg = options[:message] || 'is not a valid email address'
    record.errors[attribute] << msg unless value =~ regex
  end
end
