# frozen_string_literal: true

require 'rails_helper'

describe 'API V0 - Security and Privacy Statement Show' do
  before(:each) do
    @security_privacy_statement = create(:security_privacy_statement)
    render partial: 'api/v0/rda_common_standard/security_privacy_statements_show.json.jbuilder',
           locals: { security_privacy_statement: @security_privacy_statement }
    @json = JSON.parse(rendered)
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
