# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V0::Deserialization::Contributor do
  before(:each) do
    @affiliation = create(:affiliation)
    @provenance = Faker::Lorem.unique.word.downcase
    @name = Faker::Movies::StarWars.character
    @email = Faker::Internet.email
    @role = Api::V0::ConversionService.to_credit_taxonomy(role: 'investigation')
    @category = 'orcid'

    @contributor = create(:contributor, affiliation: @affiliation, roles: [@role],
                                        provenance: @provenance, name: @name, email: @email)
    @identifier = create(:identifier, identifiable: @contributor, provenance: @provenance,
                                      category: @category, value: SecureRandom.uuid)
    @contributor.reload
    @json = { name: @name, mbox: @email, roles: [@role] }
  end

  describe '#deserialize(provenance:, json: {})' do
    before(:each) do
      allow(described_class).to receive(:marshal_contributor).and_return(@contributor)
    end

    it 'returns nil if json is not valid' do
      result = described_class.deserialize(provenance: @provenance, json: {})
      expect(result).to eql(nil)
    end
    it 'returns nil if the Contributor is not valid' do
      allow_any_instance_of(Contributor).to receive(:valid?).and_return(false)
      result = described_class.deserialize(provenance: @provenance, json: @json)
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
        json = { roles: [@role] }
        result = described_class.send(:valid?, is_contact: true, json: json)
        expect(result).to eql(false)
      end
      context 'Contact' do
        it 'returns true without :roles' do
          json = { name: @name, mbox: @email }
          result = described_class.send(:valid?, is_contact: true, json: json)
          expect(result).to eql(true)
        end
        it 'returns true with :roles' do
          result = described_class.send(:valid?, is_contact: true, json: @json)
          expect(result).to eql(true)
        end
      end
      context 'Contributor' do
        it 'returns false without :roles' do
          json = { name: @name, mbox: @email }
          result = described_class.send(:valid?, is_contact: false, json: json)
          expect(result).to eql(false)
        end
        it 'returns true with :roles' do
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
      it 'attaches the correct roles if Contributor is the Contact' do
        result = described_class.send(:marshal_contributor, provenance: @provenance,
                                                            is_contact: true, json: @json)
        expected = Api::V0::ConversionService.to_credit_taxonomy(role: 'data_curation')
        expect(result.roles.include?(expected)).to eql(true)
      end
      it 'attaches the roles to the Contributor' do
        result = described_class.send(:marshal_contributor, provenance: @provenance,
                                                            is_contact: false, json: @json)
        expect(result.roles).to eql([@role])
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

    describe '#assign_contact_roles(contributor:)' do
      it 'returns nil if the contributor is not present' do
        result = described_class.send(:assign_contact_roles, contributor: nil)
        expect(result).to eql(nil)
      end
      it 'assigns the :data_curation role' do
        expected = Api::V0::ConversionService.to_credit_taxonomy(role: 'data_curation')
        result = described_class.send(:assign_contact_roles, contributor: @contributor)
        expect(result.roles.include?(expected)).to eql(true)
      end
    end

    describe '#assign_roles(contributor:, json:)' do
      it 'returns nil if the contributor is not present' do
        result = described_class.send(:assign_roles, contributor: nil, json: @json)
        expect(result).to eql(nil)
      end
      it 'returns the Contributor as-is if json is not present' do
        result = described_class.send(:assign_roles, contributor: @contributor, json: {})
        expect(result).to eql(@contributor)
      end
      it 'returns the Contributor as-is if json :roles is not present' do
        json = { name: @name }
        result = described_class.send(:assign_roles, contributor: @contributor, json: json)
        expect(result).to eql(@contributor)
      end
      it 'converts roles to CRediT taxonomy roles' do
        json = { roles: ['Investigation'] }
        expected = Api::V0::ConversionService.to_credit_taxonomy(role: 'investigation')
        result = described_class.send(:assign_roles, contributor: @contributor, json: json)
        expect(result.roles.last).to eql(expected)
      end
      it 'leaves url roles as-is' do
        json = { roles: [Faker::Internet.url] }
        result = described_class.send(:assign_roles, contributor: @contributor, json: json)
        expect(result.roles.last).to eql(json[:roles].first)
      end
      it 'assigns the roles' do
        result = described_class.send(:assign_roles, contributor: @contributor, json: @json)
        expect(result.roles).to eql(@json[:roles])
      end
      it 'does not duplicate roles' do
        json = { roles: %w[Investigation Investigation] }
        result = described_class.send(:assign_roles, contributor: @contributor, json: json)
        expect(result.roles.length).to eql(1)
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
        json = { contact_id: { type: 'URL', identifier: @identifier.value } }
        count = @contributor.identifiers.length
        result = described_class.send(:attach_identifier, provenance: @provenance,
                                                          contributor: @contributor, json: json)
        expect(result.identifiers.length > count).to eql(true)
        expect(result.identifiers.last.category).to eql('url')
        id = result.identifiers.last.value
        expect(id).to eql(@identifier.value)
      end
      it 'initializes the identifier and adds it to the Contributor for a :contributor_id' do
        json = { contributor_id: { type: 'URL', identifier: @identifier.value } }
        count = @contributor.identifiers.length
        result = described_class.send(:attach_identifier, provenance: @provenance,
                                                          contributor: @contributor, json: json)
        expect(result.identifiers.length > count).to eql(true)
        expect(result.identifiers.last.category).to eql('url')
        id = result.identifiers.last.value
        expect(id).to eql(@identifier.value)
      end
    end
  end
end
