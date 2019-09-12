# frozen_string_literal: true

require 'rails_helper'

describe 'API V1 - Security and Privacy Statement Show' do

  before(:each) do
    @security_privacy_statement = create(:security_privacy_statement)
    render partial: "api/v1/rda_common_standard/security_privacy_statements_show.json.jbuilder",
           locals: { security_privacy_statement: @security_privacy_statement }
    @json = JSON.parse(rendered)
  end

  it 'does not have a HATEOAS links attribute' do
    expect(@json['links'].present?).to eql(false)
  end

  it 'has base attributes' do
    validate_created_at_presence(model: @security_privacy_statement, rendered: @json)
  end

  it 'has a title attribute' do
    expect(@json['title']).to eql(@security_privacy_statement.title)
  end

  it 'has a description attribute' do
    expect(@json['description']).to eql(@security_privacy_statement.description)
  end

end

# Example structure of expected JSON output:
# {
#   "created"=>"2019-09-10 20:19:17 UTC",
#   "modified"=>"2019-09-10 20:19:17 UTC",
#   "title"=>"Eos tempora voluptate quae.",
#   "description"=>"Quos nemo voluptas. Sed dolor nesciunt. Asperiores sit ut."
# }
