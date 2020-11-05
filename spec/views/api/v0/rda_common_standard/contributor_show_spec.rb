# frozen_string_literal: true

require 'rails_helper'

describe 'API V0 - Contributor Show' do
  before(:each) do
    @contributor = create(:contributor, :complete, affiliation: create(:affiliation))
    @partial = 'api/v0/rda_common_standard/contributors_show.json.jbuilder'
  end

  context 'base person' do
    before(:each) do
      render partial: @partial, locals: { contributor: @contributor, rel: 'primary_contact' }
      @json = JSON.parse(rendered)
    end

    it 'has a name attribute' do
      expect(@json['name']).to eql(@contributor.name)
    end

    it 'has a mbox attribute' do
      expect(@json['mbox']).to eql(@contributor.email)
    end

    it 'has an affiliation attribute' do
      expect(@json['affiliation']['name']).to eql(@contributor.affiliation.name)
    end
  end

  context 'primary contact' do
    before(:each) do
      render partial: @partial, locals: { contributor: @contributor, rel: 'primary_contact' }
      @json = JSON.parse(rendered)
    end

    it 'has a contact_id attribute' do
      expect(@json['contact_id']['identifier']).to eql(@contributor.orcids.first.value)
    end
  end

  context 'other contributor' do
    before(:each) do
      render partial: @partial, locals: { contributor: @contributor, rel: 'author' }
      @json = JSON.parse(rendered)
    end

    it 'has a contributor_id attribute' do
      expect(@json['contributor_id']['identifier']).to eql(@contributor.orcids.first.value)
    end

    it 'has a roles attribute' do
      expect(@json['roles'].first['identifier']).to eql(@contributor.credits.first.value)
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
#     "identifier": "http://credit.niso.org/contributor-roles/investigation"
#   }]
# }
