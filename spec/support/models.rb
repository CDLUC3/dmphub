# frozen_string_literal: true

# methods for use with building models/objects from JSON
def open_json_mock(file_name:, part: 'complete')
  return '' unless file_name.present?

  # Open the JSON and get the appropriate part
  initial = open_json_file(file_name: file_name)[part]
  # Splice the JSON files using `"$$_file_name_$$"` to embed sub-files
  # For example `{ "complete": { "foo": "bar" } }` in `foos.json` would get spliced into
  # `{ complete: { "title": "Testing", "type": "$$_foos.json_$$" } }` would result in:
  # `{ "title": "Testing", "type": { "foo": "bar" } }`
  content = splice_json(string: JSON.generate(initial), part: part)
  JSON.parse(content)
end

# Open the JSON file
def open_json_file(file_name:)
  path = Rails.root.join('spec', 'support', 'mocks', 'json_parts')
  JSON.parse(File.read("#{path}/#{file_name}"))
end

# Find `"$$_file_$$"` patterns in the JSON and splice in the contents of that
# file's part
def splice_json(string:, part: 'complete')
  return {} unless string.present?

  file_token = /\"\$\$_[a-z.]+_\$\$\"/
  return string unless string =~ file_token

  string.gsub(file_token) do |file_name|
    json = open_json_file(file_name: file_name.gsub('"$$_', '').gsub('_$$"', ''))
    splice_json(string: JSON.generate(json[part]), part: part)
  end
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
