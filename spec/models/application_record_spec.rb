# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApplicationRecord, type: :model do

  before(:each) do
    @json = {
      'id': 12345,
      'created_at': (Time.now - 1.days).to_s,
      'updated_at': Time.now.to_s,
      'links': [{ 'rel': 'self', 'href': 'http://localhost:3000/identifiers/12345' }]
    }
  end

  it 'delete_base_json_elements removes Rails managed fields' do
    ident = Identifier.delete_base_json_elements(@json)
    expect(ident['id'].present?).to eql(false)
    expect(ident['created_at'].present?).to eql(false)
    expect(ident['updated_at'].present?).to eql(false)
    expect(ident['links'].present?).to eql(false)
  end

end
