# frozen_string_literal: true

# methods for use with building models/objects from JSON
def open_json_mock(file_name:)
  return '' unless file_name.present?

  path = Rails.root.join('spec', 'support', 'mocks', 'json_parts')
  JSON.parse(File.read("#{path}/#{file_name}"))
end

# Run validations against each of the JSON sets: invalid, minimal, complete
def validate_invalid_json_to_model(clazz:, jsons:, **args)
  obj = clazz.from_json!(merge_args(
                           json: jsons.fetch(:invalid, {}),
                           provenance: 'Testing',
                           args: args
                         ))
  expect(obj.nil?).to eql(true)
end

def validate_minimal_json_to_model(clazz:, jsons:, **args)
  @json = jsons.fetch('minimal', {})
  obj = clazz.from_json!(merge_args(
                           json: @json,
                           provenance: 'Testing',
                           args: args
                         ))
  expect(obj.is_a?(clazz)).to eql(true), "Expected #{obj.class.name} to be a #{clazz.name}"
  return obj if clazz == Identifier

  expect(obj.valid?).to eql(true), obj.errors.collect { |e, m| "#{e} - #{m}" }.join(', ')
  obj
end

def validate_complete_json_to_model(clazz:, jsons:, **args)
  @json = jsons.fetch('complete', {})
  obj = clazz.from_json!(merge_args(
                           json: @json,
                           provenance: 'Testing',
                           args: args
                         ))
  expect(obj.is_a?(clazz)).to eql(true), "Expected #{obj.class.name} to be a #{clazz.name}"
  return obj if clazz == Identifier

  expect(obj.valid?).to eql(true), obj.errors.collect { |e, m| "#{e} - #{m}" }.join(', ')
  obj
end

def merge_args(json:, provenance:, args: {})
  args.merge({ json: json, provenance: provenance })
end
