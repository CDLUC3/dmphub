# frozen_string_literal: true

require 'rails_helper'

describe 'API V1 - Person Show' do

  before(:each) do
    @person = create(:person, :complete)
    @partial = 'api/v1/rda_common_standard/persons_show.json.jbuilder'
  end

  context 'base person' do
    before(:each) do
      render partial: @partial, locals: { person: @person, rel: 'primary_contact' }
      @json = JSON.parse(rendered)
    end

    it 'has base attributes' do
      validate_base_json_elements(model: @person, rendered: @json)
    end

    it 'has a name attribute' do
      expect(@json['name']).to eql(@person.name)
    end

    it 'has a mbox attribute' do
      expect(@json['mbox']).to eql(@person.email)
    end

    it 'has an organizations attribute' do
      expect(@json['organizations'].length).to eql(@person.organizations.length)
    end
  end

  context 'primary contact' do
    before(:each) do
      render partial: @partial, locals: { person: @person, rel: 'primary_contact' }
      @json = JSON.parse(rendered)
    end

    it 'has a contact_ids attribute' do
      expect(@json['contact_ids'].length).to eql(@person.identifiers.length)
    end
  end

  context 'other contributor' do
    before(:each) do
      render partial: @partial, locals: { person: @person, rel: 'author' }
      @json = JSON.parse(rendered)
    end

    it 'has a user_ids attribute' do

p @person.identifiers.inspect
p @json

      expect(@json['user_ids'].length).to eql(@person.identifiers.length)
    end

    it 'has a contributor_type attribute' do
      expect(@json['contributor_type']).to eql('author')
    end
  end

end

# Example structure of expected JSON output for a primary contact:
# {
#   "created"=>"2019-09-09 16:31:39 UTC",
#   "modified"=>"2019-09-09 16:31:39 UTC",
#   "links"=>[{
#     "rel"=>"self",
#     "href"=>"http://localhost:3000/api/v1/persons/1"
#   }],
#   "name"=>"Sebulba",
#   "mbox"=>"sebulba@example.org",
#   "organizations"=>[ << See the organization_show_spec.rb for an example of its JSON >> ],
#   "contact_ids"=>[{
#     "created"=>"2019-09-09 16:31:39 UTC",
#     "modified"=>"2019-09-09 16:31:39 UTC",
#     "category"=>"orcid",
#     "provenance"=>"orcid",
#     "value"=>"9999999999999"
#   }]
# }

# Example structure of expected JSON output for regular person:
# {
#   "created":"2019-09-09 16:31:39 UTC",
#   "modified":"2019-09-09 16:31:39 UTC",
#   "links":[{
#     "rel":"self",
#     "href":"http://localhost:3000/api/v1/persons/16"
#   }],
#   "name":"Sebulba",
#   "mbox":"sebulba@example.org",
#   "organizations"=>[ << See the organization_show_spec.rb for an example of its JSON >> ],
#   "user_ids":[{
#     "created":"2019-09-09 16:31:39 UTC",
#     "modified":"2019-09-09 16:31:39 UTC",
#     "category":"orcid",
#     "provenance":"orcid",
#     "value":"1234567890"
#   }],
#   "contributor_type":"author"
# }
