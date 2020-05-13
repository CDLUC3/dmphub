# frozen_string_literal: true

require 'rails_helper'

describe 'API V0 - Person Show' do
  before(:each) do
    @person = create(:person, :complete)
    @partial = 'api/v0/rda_common_standard/persons_show.json.jbuilder'
  end

  context 'base person' do
    before(:each) do
      render partial: @partial, locals: { person: @person, rel: 'primary_contact' }
      @json = JSON.parse(rendered)
    end

    it 'has a name attribute' do
      expect(@json['name']).to eql(@person.name)
    end

    it 'has a mbox attribute' do
      expect(@json['mbox']).to eql(@person.email)
    end

    it 'has an organizations attribute' do
      expect(@json['affiliation']['name']).to eql(@person.organizations.first.name)
    end
  end

  context 'primary contact' do
    before(:each) do
      render partial: @partial, locals: { person: @person, rel: 'primary_contact' }
      @json = JSON.parse(rendered)
    end

    it 'has a contact_id attribute' do
      expect(@json['contact_id']['identifier']).to eql(@person.orcids.first.value)
    end
  end

  context 'other contributor' do
    before(:each) do
      render partial: @partial, locals: { person: @person, rel: 'author' }
      @json = JSON.parse(rendered)
    end

    it 'has a contributor_id attribute' do
      expect(@json['contributor_id']['identifier']).to eql(@person.orcids.first.value)
    end

    it 'has a roles attribute' do
      expect(@json['roles'].first['identifier']).to eql(@person.credits.first.value)
    end
  end
end

# Example structure of expected JSON output for a primary contact:
# {
#   "name":"Sebulba",
#   "mbox":"sebulba@example.org",
#   "affiliation"=>{ << See the organization_show_spec.rb for an example of its JSON >> },
#   "contact_id":{
#     "type":"HTTP-ORCID",
#     "identifier":"https://orcid.org/0000-0000-0000-0000"
#   }
# }

# Example structure of expected JSON output for a contributor:
# {
#   "name":"Sebulba",
#   "mbox":"sebulba@example.org",
#   "affiliation"=>{ << See the organization_show_spec.rb for an example of its JSON >> },
#   "contributor_id":{
#     "type":"HTTP-ORCID",
#     "identifier":"https://orcid.org/0000-0000-0000-0000"
#   },
#   "roles":[{
#     "type":"HTTP-CASRAI",
#     "identifier": "https://dictionary.casrai.org/Contributor_Roles/Investigation"
#   }]
# }
