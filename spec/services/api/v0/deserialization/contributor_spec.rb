# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V0::Deserialization::Contributor do
  before(:each) do
    @affiliation = create(:affiliation)
    @provenance = create(:provenance)
    @name = Faker::Movies::StarWars.character
    @email = Faker::Internet.email
    @role = Api::V0::ConversionService.to_credit_taxonomy(role: 'investigation')
    @category = 'orcid'

    @contributor = create(:contributor, affiliation: @affiliation, provenance: @provenance,
                                        name: @name, email: @email)
    @identifier = create(:identifier, identifiable: @contributor, provenance: @provenance,
                                      category: @category, value: SecureRandom.uuid)
    @contributor.reload
    @json = { name: @name, mbox: @email, role: [@role] }
  end

  describe '#deserialize(provenance:, json: {})' do
    before(:each) do
      allow(described_class).to receive(:marshal_contributor).and_return(@contributor)
    end

    it 'returns nil if json is not valid' do
      result = described_class.deserialize(provenance: @provenance, json: {})
      expect(result).to eql(nil)
    end
    it 'calls attach_identifier' do
      allow(described_class).to receive(:attach_identifier).and_return(@contributor)
      described_class.deserialize(provenance: @provenance, json: @json)
      expect(described_class).to have_received(:attach_identifier)
    end
    it 'returns the Contributor' do
      result = described_class.deserialize(provenance: @provenance, json: @json)
      expect(result).to eql(@contributor)
    end
  end

  context 'private methods' do
    describe '#valid?(is_contact:, json:)' do
      it 'returns false if json is not present' do
        result = described_class.send(:valid?, is_contact: true, json: nil)
        expect(result).to eql(false)
      end
      it 'returns false if :name and :mbox are not present' do
        result = described_class.send(:valid?, is_contact: true, json: {})
        expect(result).to eql(false)
      end
      context 'Contact' do
        it 'returns true without :role' do
          json = { name: @name, mbox: @email }
          result = described_class.send(:valid?, is_contact: true, json: json)
          expect(result).to eql(true)
        end
        it 'returns true with :role' do
          result = described_class.send(:valid?, is_contact: true, json: @json)
          expect(result).to eql(true)
        end
      end
      context 'Contributor' do
        it 'returns false without :role' do
          json = { name: @name, mbox: @email }
          result = described_class.send(:valid?, is_contact: false, json: json)
          expect(result).to eql(false)
        end
        it 'returns true with :role' do
          result = described_class.send(:valid?, is_contact: false, json: @json)
          expect(result).to eql(true)
        end
      end
    end

    describe '#marshal_contributor(provenance:, is_contact:, json:)' do
      it 'returns nil if json is not valid' do
        result = described_class.send(:marshal_contributor, provenance: @provenance,
                                                            is_contact: true, json: {})
        expect(result).to eql(nil)
      end
      it 'finds the Contributor by its identifier' do
        result = described_class.send(:marshal_contributor, provenance: @provenance,
                                                            is_contact: true, json: @json)
        expect(result).to eql(@contributor)
      end
      it 'finds the Contributor by its name/email' do
        allow(described_class).to receive(:find_by_identifier).and_return(nil)
        result = described_class.send(:marshal_contributor, provenance: @provenance,
                                                            is_contact: true, json: @json)
        expect(result).to eql(@contributor)
      end
      it 'initializes a Contributor by its name/email' do
        allow(described_class).to receive(:find_by_identifier).and_return(nil)
        allow(::Contributor).to receive(:where).and_return([])
        result = described_class.send(:marshal_contributor, provenance: @provenance,
                                                            is_contact: true, json: @json)
        expect(result.new_record?).to eql(true)
      end
      it 'attaches the Affiliation to the Contributor' do
        allow(described_class).to receive(:deserialize_affiliation).and_return(@affiliation)
        result = described_class.send(:marshal_contributor, provenance: @provenance,
                                                            is_contact: true, json: @json)
        expect(result.affiliation).to eql(@affiliation)
      end
    end

    describe '#find_by_identifier(provenance:, json:)' do
      before(:each) do
        allow(Api::V0::Deserialization::Identifier).to receive(:deserialize).and_return(@identifier)
      end
      it 'returns nil if json is not present' do
        expect(described_class.send(:find_by_identifier, provenance: @provenance, json: {})).to eql(nil)
      end
      it 'returns nil if :contact_id and :contributor_id are not present' do
        expect(described_class.send(:find_by_identifier, provenance: @provenance, json: @json)).to eql(nil)
      end
      it 'finds the Contributor by :contact_id' do
        json = { contact_id: { type: @category, identifier: @identifier.value } }
        result = described_class.send(:find_by_identifier, provenance: @provenance, json: json)
        expect(result).to eql(@contributor)
      end
      it 'finds the Contributor by :contributor_id' do
        json = { contributor_id: { type: @category, identifier: @identifier.value } }
        result = described_class.send(:find_by_identifier, provenance: @provenance, json: json)
        expect(result).to eql(@contributor)
      end
      it 'returns nil if no Contributor was found' do
        allow(Api::V0::Deserialization::Identifier).to receive(:deserialize).and_return(nil)
        expect(described_class.send(:find_by_identifier, provenance: @provenance, json: @json)).to eql(nil)
      end
    end

    describe '#find_by_email_or_name(provenance:, is_contact:, json: {})' do
      it 'returns nil if json is not valid' do
        result = described_class.send(:find_by_email_or_name, provenance: @provenance,
                                                              is_contact: true, json: {})
        expect(result).to eql(nil)
      end
      it 'finds the Contributor by its email' do
        result = described_class.send(:find_by_email_or_name, provenance: @provenance,
                                                              is_contact: true, json: @json)
        expect(result).to eql(@contributor)
      end
      it 'finds the Contributor by its name' do
        allow(described_class).to receive(:find_by_email).and_return(nil)
        result = described_class.send(:find_by_email_or_name, provenance: @provenance,
                                                              is_contact: true, json: @json)
        expect(result).to eql(@contributor)
      end
      it 'initializes a Contributor' do
        allow(described_class).to receive(:find_by_email).and_return(nil)
        allow(::Contributor).to receive(:where).and_return([])
        result = described_class.send(:find_by_email_or_name, provenance: @provenance,
                                                              is_contact: true, json: @json)
        expect(result.new_record?).to eql(true)
        expect(result.name).to eql(@name)
        expect(result.email).to eql(@email)
      end
    end

    describe '#find_by_email(provenance:, json: {})' do
      it 'returns nil if json is not valid' do
        result = described_class.send(:find_by_email_or_name, provenance: @provenance,
                                                              is_contact: true, json: {})
        expect(result).to eql(nil)
      end
      it 'finds the matching Contributor by email' do
        result = described_class.send(:find_by_email_or_name, provenance: @provenance,
                                                              is_contact: true, json: @json)
        expect(result).to eql(@contributor)
      end
    end

    describe '#find_by_name(provenance:, json: {})' do
      it 'returns nil if :name is not in json' do
        result = described_class.send(:find_by_email_or_name, provenance: @provenance,
                                                              is_contact: true, json: {})
        expect(result).to eql(nil)
      end
      it 'finds the matching Contributor by name' do
        @json[:mbox] = 'foo@example.org'
        result = described_class.send(:find_by_email_or_name, provenance: @provenance,
                                                              is_contact: true, json: @json)
        expect(result).to eql(@contributor)
      end
      it 'initializes the Contributor if there were no viable matches' do
        json = {
          name: Faker::TvShows::Simpsons.character,
          mbox: Faker::Internet.unique.email
        }
        result = described_class.send(:find_by_email_or_name, provenance: @provenance,
                                                              is_contact: true, json: json)
        expect(result.new_record?).to eql(true)
        expect(result.name).to eql(json[:name])
        expect(result.email).to eql(json[:mbox])
      end
    end

    describe '#deserialize_affiliation(provenance:, json:)' do
      it 'returns nil if json is not present' do
        result = described_class.send(:deserialize_affiliation, provenance: @provenance, json: {})
        expect(result).to eql(nil)
      end
      it 'returns nil if json :affiliation is not present' do
        result = described_class.send(:deserialize_affiliation, provenance: @provenance, json: @json)
        expect(result).to eql(nil)
      end
      it 'calls the Affiliation.deserialize method' do
        allow(Api::V0::Deserialization::Affiliation).to receive(:deserialize).and_return(@affiliation)
        json = { affiliation: { name: @affiliation.name } }
        described_class.send(:deserialize_affiliation, provenance: @provenance, json: json)
        expect(Api::V0::Deserialization::Affiliation).to have_received(:deserialize)
      end
    end

    describe '#attach_identifier(provenance:, contributor:, json:)' do
      it 'returns the Contributor as-is if json is not present' do
        result = described_class.send(:attach_identifier, provenance: @provenance,
                                                          contributor: @contributor, json: {})
        expect(result.identifiers).to eql(@contributor.identifiers)
      end
      it 'returns the Affiliation as-is if the json has no identifier' do
        json = { name: @name }
        result = described_class.send(:attach_identifier, provenance: @provenance,
                                                          contributor: @contributor, json: json)
        expect(result.identifiers).to eql(@contributor.identifiers)
      end
      it 'returns the Affiliation as-is if the Contributor already has the :contact_id' do
        json = { contact_id: { type: @category, identifier: @identifier.value } }
        result = described_class.send(:attach_identifier, provenance: @provenance,
                                                          contributor: @contributor, json: json)
        expect(result.identifiers).to eql(@contributor.identifiers)
      end
      it 'returns the Affiliation as-is if the Contributor already has the :contributor_id' do
        json = { contributor_id: { type: @category, identifier: @identifier.value } }
        result = described_class.send(:attach_identifier, provenance: @provenance,
                                                          contributor: @contributor, json: json)
        expect(result.identifiers).to eql(@contributor.identifiers)
      end
      it 'initializes the identifier and adds it to the Contributor for a :contact_id' do
        json = { contact_id: { type: 'URL', identifier: Faker::Internet.url } }
        result = described_class.send(:attach_identifier, provenance: @provenance,
                                                          contributor: build(:contributor), json: json)
        expect(result.identifiers.length).to eql(1)
        expect(result.identifiers.last.category).to eql('url')
        expect(result.identifiers.last.value).to eql(json[:contact_id][:identifier])
      end
      it 'initializes the identifier and adds it to the Contributor for a :contributor_id' do
        json = { contributor_id: { type: 'URL', identifier: Faker::Internet.url } }
        count = @contributor.identifiers.length
        result = described_class.send(:attach_identifier, provenance: @provenance,
                                                          contributor: build(:contributor), json: json)
        expect(result.identifiers.length).to eql(1)
        expect(result.identifiers.last.category).to eql('url')
        expect(result.identifiers.last.value).to eql(json[:contributor_id][:identifier])
      end
    end
  end

  context 'Updates' do
    before(:each) do
      @json = {
        name: Faker::Movies::StarWars.unique.character,
        mbox: Faker::Internet.unique.email,
        role: [::ContributorsDataManagementPlan.roles.keys.reject { |k| k == 'primary_contact' }.sample],
        contributor_id: {
          type: ::Identifier.categories.keys.reject { |c| c == @contributor.identifiers.first.category }.sample,
          identifier: Faker::Internet.unique.url
        }
      }
    end
    it 'does not update the fields if no match is found in DB' do
      result = described_class.deserialize(provenance: @provenance, json: @json)
      expect(result.new_record?).to eql(true)
    end
    it 'updates the record if matched by :identifier' do
      @json[:contributor_id] = {
        type: @contributor.identifiers.first.category,
        identifier: @contributor.identifiers.first.value
      }
      contrib = described_class.deserialize(provenance: @provenance, json: @json)
      # Expect the identifier not to have changed!
      expect(contrib.identifiers.last).to eql(@contributor.identifiers.last)
      expect(contrib.email).to eql(@json[:mbox])
      expect(contrib.name).to eql(@json[:name])
    end
    it 'updates the record if matched by :email' do
      @json[:mbox] = @contributor.email
      contrib = described_class.deserialize(provenance: @provenance, json: @json)
      # Expect the email not to have changed!
      expect(contrib.email).to eql(@contributor.email)
      expect(contrib.name).to eql(@json[:name])
      expect(contrib.identifiers.last.category).to eql(@json[:contributor_id][:type])
      expect(contrib.identifiers.last.value).to eql(@json[:contributor_id][:identifier])
    end
  end
end
