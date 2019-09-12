# frozen_string_literal: true

require 'rails_helper'

describe 'API V1 - Award Show' do

  before(:each) do
    @license = create(:license)
    render partial: 'api/v1/rda_common_standard/licenses_show.json.jbuilder',
           locals: { license: @license }
    @json = JSON.parse(rendered)
  end

  it 'does not have a HATEOAS links attribute' do
    expect(@json['links'].present?).to eql(false)
  end

  it 'has base attributes' do
    validate_created_at_presence(model: @license, rendered: @json)
  end

  it 'has a license_ref attribute' do
    expect(@json['license_ref']).to eql(@license.license_uri)
  end

  it 'has a start_date attribute' do
    expect(@json['start_date']).to eql(@license.start_date.to_s)
  end

end

# Example structure of expected JSON output:
# {
#   "created"=>"2019-09-10 18:45:36 UTC",
#   "modified"=>"2019-09-10 18:45:36 UTC",
#   "links"=>[{
#     "rel"=>"self",
#     "href"=>"http://localhost:3000/api/v1/licenses/2"
#   }],
#   "license_ref"=>"http://boyleheaney.org/ellsworth",
#   "start_date"=>"2019-10-10 18:45:36 UTC"
# }
