# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V0::Deserialization::Dataset do
  before(:each) do
    @provenance = create(:provenance)
    @dmp = create(:data_management_plan, provenance: @provenance)
    @dataset = create(:dataset, provenance: @provenance, data_management_plan: @dmp)
    @host = create(:host)
    create(:identifier, identifiable: @host, category: 'url', value: Faker::Internet.url,
                        descriptor: 'is_identified_by')
    @host.reload
    @distribution = create(:distribution, provenance: @provenance, dataset: @dataset, host: @host)
    @identifier = create(:identifier, identifiable: @dataset,
                                      category: Identifier.requires_universal_uniqueness.sample.to_s,
                                      descriptor: Identifier.descriptors.keys.sample,
                                      value: Faker::Internet.url)

    metadatum = create(:metadatum, dataset: @dataset, provenance: @provenance)
    create(:identifier, identifiable: metadatum, value: Faker::Internet.url,
                        category: Identifier.requires_universal_uniqueness.sample.to_s)
    create(:security_privacy_statement, dataset: @dataset, provenance: @provenance)
    create(:technical_resource, dataset: @dataset, provenance: @provenance)
    create(:dataset_keyword, dataset: @dataset, keyword: create(:keyword))
    @dataset.reload

    # Full sample Dataset w/minimal associated objects
    @json = {
      title: Faker::Lorem.sentence,
      type: Dataset.dataset_types.keys.sample,
      personal_data: %w[yes no unknown].sample,
      sensitive_data: %w[yes no unknown].sample,
      data_quality_assurance: Faker::Lorem.paragraph,
      dataset_id: { type: Identifier.categories.keys.sample, identifier: SecureRandom.uuid },
      description: Faker::Lorem.paragraph,
      distribution: [{ title: Faker::Lorem.sentence, data_access: Distribution.data_accesses.keys.sample }],
      issued: (Time.now + 65.days).utc.to_formatted_s(:iso8601),
      keyword: [Faker::Lorem.unique.word, Faker::Lorem.unique.word],
      language: Api::V0::ConversionService::LANGUAGES.sample,
      metadata: [
        { metadata_standard_id: { type: Identifier.categories.keys.sample, identifier: Faker::Internet.url } }
      ],
      preservation_statement: Faker::Lorem.paragraph,
      security_and_privacy: [{ title: Faker::Lorem.sentence }],
      technical_resource: [{ title: Faker::Lorem.sentence }]
    }
  end

  describe '#deserialize(provenance:, dataset:, json: {})' do
    it 'returns nil if :provenance is not present' do
      result = described_class.deserialize(provenance: nil, dmp: @dmp, json: @json)
      expect(result).to eql(nil)
    end
    it 'returns nil if :dmp is not present' do
      result = described_class.deserialize(provenance: @provenance, dmp: nil, json: @json)
      expect(result).to eql(nil)
    end
    it 'returns nil if json[:title] is not present' do
      @json.delete(:title)
      result = described_class.deserialize(provenance: @provenance, dmp: @dmp, json: @json)
      expect(result).to eql(nil)
    end
    it 'returns nil if json[:dataset_id] is not present' do
      @json.delete(:dataset_id)
      result = described_class.deserialize(provenance: @provenance, dmp: @dmp, json: @json)
      expect(result).to eql(nil)
    end
    it 'finds an existing Dataset by its :dataset_id' do
      @json[:dataset_id] = { type: @identifier.category, identifier: @identifier.value }
      result = described_class.deserialize(provenance: @provenance, dmp: @dmp, json: @json)
      expect(result.new_record?).to eql(false)
    end
    it 'finds an existing Dataset by its :title' do
      @json[:title] = @dataset.title
      result = described_class.deserialize(provenance: @provenance, dmp: @dmp, json: @json)
      expect(result.new_record?).to eql(false)
    end
    it 'initializes a new Dataset' do
      result = described_class.deserialize(provenance: @provenance, dmp: @dmp, json: @json)
      expect(result.new_record?).to eql(true)
    end
  end

  context 'private methods' do
    describe '#valid?(json:)' do
      it 'returns false if json is empty' do
        expect(described_class.send(:valid?, json: {})).to eql(false)
      end
      it 'returns false if :title is not present' do
        @json.delete(:title)
        expect(described_class.send(:valid?, json: @json)).to eql(false)
      end
      it 'returns false if :dataset_id is not present' do
        @json.delete(:dataset_id)
        expect(described_class.send(:valid?, json: @json)).to eql(false)
      end
      it 'returns true if :title and :dataset_id present' do
        expect(described_class.send(:valid?, json: @json)).to eql(true)
      end
    end

    describe '#find_by_identifier(provenance:, json: {})' do
      it 'returns nil if dataset_id[:identifier] is not present' do
        @json[:dataset_id].delete(:identifier)
        result = described_class.send(:find_by_identifier, provenance: @provenance, json: @json)
        expect(result).to eql(nil)
      end
      it 'finds the Dataset by :dataset_id' do
        @json[:dataset_id] = { type: @identifier.category, identifier: @identifier.value }
        result = described_class.send(:find_by_identifier, provenance: @provenance, json: @json)
        expect(result).to eql(@dataset)
      end
    end

    describe '#find_by_title(provenance:, dmp:, json: {})' do
      it 'returns nil if :json is not present' do
        result = described_class.send(:find_by_title, provenance: @provenance, dmp: @dmp, json: nil)
        expect(result).to eql(nil)
      end
      it 'returns nil if dmp is not present' do
        @json.delete(:title)
        result = described_class.send(:find_by_title, provenance: @provenance, dmp: nil, json: @json)
        expect(result).to eql(nil)
      end
      it 'finds the Dataset by :title and :data_management_plan' do
        @json[:title] = @dataset.title
        result = described_class.send(:find_by_title, provenance: @provenance, dmp: @dmp, json: @json)
        expect(result).to eql(@dataset)
      end
      it 'initializes a new Dataset if the DataManagementPlan has not been persisted' do
        result = described_class.send(:find_by_title, provenance: @provenance, dmp: @dmp, json: @json)
        expect(result.new_record?).to eql(true)
      end
      it 'initializes a new Dataset if no match is found' do
        result = described_class.send(:find_by_title, provenance: @provenance, dmp: @dmp, json: @json)
        expect(result.new_record?).to eql(true)
      end
    end

    describe '#attach_identifier(provenance:, dataset:, json:)' do
      it 'returns the Dataset as-is if json is not present' do
        result = described_class.send(:attach_identifier, provenance: @provenance, dataset: @dataset, json: {})
        expect(result.identifiers).to eql(@dataset.identifiers)
      end
      it 'returns the Dataset as-is if :dmp_id is not present' do
        @json.delete(:dataset_id)
        result = described_class.send(:attach_identifier, provenance: @provenance, dataset: @dataset,
                                                          json: @json)
        expect(result.identifiers).to eql(@dataset.identifiers)
      end
      it 'initializes the identifier and adds it to the Dataset' do
        result = described_class.send(:attach_identifier, provenance: @provenance, dataset: build(:dataset),
                                                          json: @json)
        expect(result.identifiers.length).to eql(1)
        expect(result.identifiers.last.category).to eql(@json[:dataset_id][:type])
        expect(result.identifiers.last.value).to eql(@json[:dataset_id][:identifier])
      end
    end

    describe '#deserialize_keywords(provenance:, dataset:, json:)' do
      it 'returns the Dataset as-is if provenance is not present' do
        result = described_class.send(:deserialize_keywords, provenance: nil, dataset: @dataset, json: @json)
        expect(result.keywords).to eql(@dataset.keywords)
      end
      it 'returns nil if dataset is not present' do
        result = described_class.send(:deserialize_keywords, provenance: @provenance, dataset: nil, json: @json)
        expect(result).to eql(nil)
      end
      it 'returns the Dataset as-is if json is not present' do
        result = described_class.send(:deserialize_keywords, provenance: @provenance, dataset: @dataset,
                                                             json: nil)
        expect(result.keywords).to eql(@dataset.keywords)
      end
      it 'adds the keywords to the Dataset' do
        result = described_class.send(:deserialize_keywords, provenance: @provenance, dataset: build(:dataset),
                                                             json: @json)
        expect(result.keywords.length).to eql(@json[:keyword].length)
        @json[:keyword].each { |keyword| expect(result.keywords.map(&:value).include?(keyword)).to eql(true) }
      end
    end

    describe '#deserialize_metadata(provenance:, dataset:, json:)' do
      it 'returns the Dataset as-is if provenance is not present' do
        result = described_class.send(:deserialize_metadata, provenance: nil, dataset: @dataset, json: @json)
        expect(result.metadata).to eql(@dataset.metadata)
      end
      it 'returns nil if dataset is not present' do
        result = described_class.send(:deserialize_metadata, provenance: @provenance, dataset: nil, json: @json)
        expect(result).to eql(nil)
      end
      it 'returns the Dataset as-is if json is not present' do
        result = described_class.send(:deserialize_metadata, provenance: @provenance, dataset: @dataset,
                                                             json: nil)
        expect(result.metadata).to eql(@dataset.metadata)
      end
      it 'adds the Metadata to the Dataset' do
        result = described_class.send(:deserialize_metadata, provenance: @provenance, dataset: build(:dataset),
                                                             json: @json)
        expect(result.metadata.length).to eql(@json[:metadata].length)
        metadatum = result.metadata.last
        json_metadata = @json[:metadata].last
        expect(metadatum.identifiers.last.category).to eql(json_metadata[:metadata_standard_id][:type])
        expect(metadatum.identifiers.last.value).to eql(json_metadata[:metadata_standard_id][:identifier])
      end
    end

    describe '#deserialize_security_privacy_statements(provenance:, dataset:, json:)' do
      it 'returns the Dataset as-is if provenance is not present' do
        result = described_class.send(:deserialize_security_privacy_statements, provenance: nil,
                                                                                dataset: @dataset, json: @json)
        expect(result.security_privacy_statements).to eql(@dataset.security_privacy_statements)
      end
      it 'returns nil if dataset is not present' do
        result = described_class.send(:deserialize_security_privacy_statements, provenance: @provenance,
                                                                                dataset: nil, json: @json)
        expect(result).to eql(nil)
      end
      it 'returns the Dataset as-is if json is not present' do
        result = described_class.send(:deserialize_security_privacy_statements, provenance: @provenance,
                                                                                dataset: @dataset, json: nil)
        expect(result.security_privacy_statements).to eql(@dataset.security_privacy_statements)
      end
      it 'adds the SecurityPrivacyStatement to the Dataset' do
        result = described_class.send(:deserialize_security_privacy_statements, provenance: @provenance,
                                                                                dataset: build(:dataset),
                                                                                json: @json)
        expect(result.security_privacy_statements.length).to eql(@json[:security_and_privacy].length)
        expect(result.security_privacy_statements.last.title).to eql(@json[:security_and_privacy].last[:title])
      end
    end

    describe '#deserialize_technical_resources(provenance:, dataset:, json:)' do
      it 'returns the Dataset as-is if provenance is not present' do
        result = described_class.send(:deserialize_technical_resources, provenance: nil, dataset: @dataset,
                                                                        json: @json)
        expect(result.technical_resources).to eql(@dataset.technical_resources)
      end
      it 'returns nil if dataset is not present' do
        result = described_class.send(:deserialize_technical_resources, provenance: @provenance, dataset: nil,
                                                                        json: @json)
        expect(result).to eql(nil)
      end
      it 'returns the Dataset as-is if json is not present' do
        result = described_class.send(:deserialize_technical_resources, provenance: @provenance,
                                                                        dataset: @dataset, json: nil)
        expect(result.technical_resources).to eql(@dataset.technical_resources)
      end
      it 'adds the TechnicalResource to the Dataset' do
        result = described_class.send(:deserialize_technical_resources, provenance: @provenance,
                                                                        dataset: build(:dataset), json: @json)
        expect(result.technical_resources.length).to eql(@json[:technical_resource].length)
        expect(result.technical_resources.last.title).to eql(@json[:technical_resource].last[:title])
      end
    end

    describe '#deserialize_distributions(provenance:, dataset:, json:)' do
      it 'returns the Dataset as-is if provenance is not present' do
        result = described_class.send(:deserialize_distributions, provenance: nil, dataset: @dataset,
                                                                  json: @json)
        expect(result.distributions).to eql(@dataset.distributions)
      end
      it 'returns nil if dataset is not present' do
        result = described_class.send(:deserialize_distributions, provenance: @provenance, dataset: nil,
                                                                  json: @json)
        expect(result).to eql(nil)
      end
      it 'returns the Dataset as-is if json is not present' do
        result = described_class.send(:deserialize_distributions, provenance: @provenance, dataset: @dataset,
                                                                  json: nil)
        expect(result.distributions).to eql(@dataset.distributions)
      end
      it 'adds the Distribution to the Dataset' do
        result = described_class.send(:deserialize_distributions, provenance: @provenance,
                                                                  dataset: build(:dataset), json: @json)
        expect(result.distributions.length).to eql(@json[:distribution].length)
        expect(result.distributions.last.title).to eql(@json[:distribution].last[:title])
        expect(result.distributions.last.data_access).to eql(@json[:distribution].last[:data_access])
      end
    end
  end

  context 'Updates' do
    it 'does not update the fields if no match is found in DB' do
      result = described_class.deserialize(provenance: @provenance, dmp: @dmp, json: @json)
      expect(result.new_record?).to eql(true)
    end
    it 'updates the record if matched by :dataset_id' do
      @json[:dataset_id] = { type: @identifier.category, identifier: @identifier.value }
      count = @dataset.identifiers.length
      result = verify_expected_updates
      # Expect that it did not update the :dataset_id but did update the :title
      expect(result.title).to eql(@json[:title])
      expect(result.identifiers.length).to eql(count)
      expect(result.identifiers.include?(@identifier)).to eql(true)
    end
    it 'updates the record if matched by :title' do
      @json[:title] = @dataset.title
      count = @dataset.identifiers.length
      result = verify_expected_updates
      # Updates the :dataset_id in this scenario
      expect(result.title).to eql(@dataset[:title])
      expect(result.identifiers.length).to eql(count + 1)
      expect(result.identifiers.include?(@identifier)).to eql(true)
      expect(result.identifiers.map(&:value).include?(@json[:dataset_id][:identifier])).to eql(true)
    end
  end

  # rubocop:disable Metrics/AbcSize
  def verify_expected_updates
    result = described_class.deserialize(provenance: @provenance, dmp: @dmp, json: @json)
    expect(result.personal_data).to eql(Api::V0::ConversionService.yes_no_unknown_to_boolean(@json[:personal_data]))
    expect(result.sensitive_data).to eql(Api::V0::ConversionService.yes_no_unknown_to_boolean(@json[:sensitive_data]))
    expect(result.description).to eql(@json[:description])
    expect(result.publication_date.to_formatted_s(:iso8601)).to eql(@json[:issued])
    expect(result.preservation_statement).to eql(@json[:preservation_statement])
    expect(result.data_quality_assurance).to eql(@json[:data_quality_assurance])

    # Replaced the keywords
    expect(result.keywords.map(&:value)).to eql(@json[:keyword])
    # Added the new associations
    standard_ids = result.metadata.map { |m| m.identifiers.last.value }
    expect(standard_ids.include?(@dataset.metadata.first.identifiers.last.value)).to eql(true)
    expect(standard_ids.include?(@json[:metadata].first[:metadata_standard_id][:identifier])).to eql(true)
    statements = result.security_privacy_statements.map(&:title)
    expect(statements.include?(@dataset.security_privacy_statements.first[:title])).to eql(true)
    expect(statements.include?(@json[:security_and_privacy].first[:title])).to eql(true)
    resources = result.technical_resources.map(&:title)
    expect(resources.include?(@dataset.technical_resources.first[:title])).to eql(true)
    expect(resources.include?(@json[:technical_resource].first[:title])).to eql(true)
    distros = result.distributions.map(&:title)
    expect(distros.include?(@dataset.distributions.first[:title])).to eql(true)
    expect(distros.include?(@json[:distribution].first[:title])).to eql(true)
    result
  end
  # rubocop:enable Metrics/AbcSize
end
