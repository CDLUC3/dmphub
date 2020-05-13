# frozen_string_literal: true

require 'rails_helper'

describe 'API V0 - Award Show' do
  before(:each) do
    @license = create(:license)
    render partial: 'api/v0/rda_common_standard/licenses_show.json.jbuilder',
           locals: { license: @license }
    @json = JSON.parse(rendered)
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
#   "links"=>[{
#     "rel"=>"self",
#     "href"=>"http://localhost:3000/api/v1/licenses/2"
#   }],
#   "license_ref"=>"http://boyleheaney.org/ellsworth",
#   "start_date"=>"2019-10-10 18:45:36 UTC"
# }
