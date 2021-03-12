# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V0::Deserialization::DataManagementPlan do
  before(:each) do
    @provenance = create(:provenance)
    @dmp = create(:data_management_plan, :complete, provenance: @provenance)
    @dmp.reload

    @json = {
      title: Faker::Lorem.sentence,
      created: (Time.now - 2.months).utc.to_formatted_s(:iso8601),
      modified: Time.now.utc.to_formatted_s(:iso8601),
      description: Faker::Lorem.paragraph,
      language: Api::V0::ConversionService::LANGUAGES.sample,
      ethical_issues_exist: %w[yes no unknown].sample,
      ethical_issues_report: Faker::Internet.url,
      ethical_issues_description: Faker::Lorem.paragraph,
      dmp_id: {
        type: Identifier.categories.keys.sample, identifier: SecureRandom.uuid
      },
      contact: {
        name: Faker::Music::PearlJam.unique.musician, mbox: Faker::Internet.unique.email
      },
      contributor: [
        {
          name: Faker::Music::PearlJam.unique.musician,
          mbox: Faker::Internet.unique.email,
          role: [::ContributorsDataManagementPlan.roles.keys.reject { |k| k == 'primary_contact' }.sample]
        }
      ],
      cost: [
        {
          title: Faker::Lorem.sentence,
          currency_code: Api::V0::ConversionService::CURRENCY_CODES.sample,
          value: Faker::Number.number
        }
      ],
      project: [{ title: Faker::Music::PearlJam.album }],
      dataset: [
        {
          title: Faker::Music::PearlJam.song,
          data_acces: ::Dataset.dataset_types.keys.sample,
          dataset_id: { type: Identifier.categories.keys.sample, value: SecureRandom.uuid }
        }
      ],
      dmproadmap_related_identifiers: [
        {
          type: Identifier.categories.keys.sample,
          descriptor: Identifier.descriptors.keys.reject { |k| %w[is_identified_by is_metadata_for].include?(k) }.sample,
          identifier: SecureRandom.uuid
        }
      ]
    }
  end

  describe '#deserialize(provenance:, json: {})' do
    it 'returns nil if :provenance is not present' do
      result = described_class.deserialize(provenance: nil, json: @json)
      expect(result).to eql(nil)
    end
    it 'returns nil if json is not valid' do
      result = described_class.deserialize(provenance: @provenance, json: nil)
      expect(result).to eql(nil)
    end
    it 'returns nil if the dmp can not be deserialized' do
      @json.delete(:title)
      result = described_class.deserialize(provenance: @provenance, json: @json)
      expect(result).to eql(nil)
    end
    it 'calls :find_by_identifier' do
      allow(described_class).to receive(:find_by_identifier).and_return(@dmp)
      described_class.deserialize(provenance: @provenance, json: @json)
      expect(described_class).to have_received(:find_by_identifier)
    end
    it 'calls Api::V0::Contributor.deserialize' do
      allow(Api::V0::Deserialization::Contributor).to receive(:deserialize).and_return(@dmp.primary_contact)
      described_class.deserialize(provenance: @provenance, json: @json)
      expect(Api::V0::Deserialization::Contributor).to have_received(:deserialize).thrice
    end
    it 'calls :find_by_contact_and_title' do
      allow(described_class).to receive(:find_by_contact_and_title).and_return(@dmp)
      described_class.deserialize(provenance: @provenance, json: @json)
      expect(described_class).to have_received(:find_by_contact_and_title)
    end
    it 'calls the :deserialze methods for the associations' do
      allow(described_class).to receive(:deserialize_projects).and_return(@dmp)
      allow(described_class).to receive(:deserialize_contributors).and_return(@dmp)
      allow(described_class).to receive(:deserialize_costs).and_return(@dmp)
      allow(described_class).to receive(:deserialize_datasets).and_return(@dmp)
      allow(described_class).to receive(:deserialize_related_identifiers).and_return(@dmp)
      described_class.deserialize(provenance: @provenance, json: @json)

      expect(described_class).to have_received(:deserialize_projects)
      expect(described_class).to have_received(:deserialize_contributors)
      expect(described_class).to have_received(:deserialize_costs)
      expect(described_class).to have_received(:deserialize_datasets)
      expect(described_class).to have_received(:deserialize_related_identifiers)
    end
    it 'sets the values' do
      result = described_class.deserialize(provenance: @provenance, json: @json)
      expect(result.title).to eql(@json[:title])
      expect(result.version.to_formatted_s(:iso8601)).to eql(@json[:modified])
      expect(result.description).to eql(@json[:description])
      expect(result.language).to eql(@json[:language])
      expect(Api::V0::ConversionService.boolean_to_yes_no_unknown(result.ethical_issues)).to eql(@json[:ethical_issues_exist])
      expect(result.ethical_issues_report).to eql(@json[:ethical_issues_report])
      expect(result.ethical_issues_description).to eql(@json[:ethical_issues_description])
      expect(result.primary_contact.email).to eql(@json[:contact][:mbox])
    end
  end

  context 'private methods' do
    describe '#valid?(json:)' do
      it 'returns false if json is not present' do
        expect(described_class.send(:valid?, json: {})).to eql(false)
      end
      it 'returns true if :title, dmp_id[:identifier] and contact[:mbox] are present' do
        expect(described_class.send(:valid?, json: @json)).to eql(true)
      end
      it 'returns false if :title is not present' do
        @json.delete(:title)
        expect(described_class.send(:valid?, json: @json)).to eql(false)
      end
      it 'returns false if dmp_id[:identifier] is not present' do
        @json[:dmp_id].delete(:identifier)
        expect(described_class.send(:valid?, json: @json)).to eql(false)
      end
      it 'returns false if contact[:mbox] and contact[:contact_id][:identifier] is not present' do
        @json[:contact].delete(:mbox)
        @json[:contact].delete(:contact_id)
        expect(described_class.send(:valid?, json: @json)).to eql(false)
      end
      it 'returns true' do
        expect(described_class.send(:valid?, json: @json)).to eql(true)
      end
    end

    describe '#get_version(value: "")' do
      it 'returns the current Time as UTC if the value is not a parseable Time' do
        now = Time.now.utc
        version = described_class.send(:get_version, value: Faker::Lorem.word)
        expect(version.is_a?(Time)).to eql(true)
        expect(version >= now).to eql(true)
      end
      it 'returns the Date as a UTC Time' do
        val = Date.today
        version = described_class.send(:get_version, value: val.to_s)
        expect(version.is_a?(Time)).to eql(true)
        expect(version.to_formatted_s(:iso8601)).to eql(DateTime.parse(val.to_s).utc.to_formatted_s(:iso8601))
      end
      it 'returns the Time as UTC' do
        val = Time.now
        version = described_class.send(:get_version, value: val.to_s)
        expect(version.is_a?(Time)).to eql(true)
        expect(version.to_formatted_s(:iso8601)).to eql(val.utc.to_formatted_s(:iso8601))
      end
      it 'returns the Time as is if its already in UTC' do
        val = Time.now.utc
        version = described_class.send(:get_version, value: val.to_s)
        expect(version.is_a?(Time)).to eql(true)
        expect(version.to_formatted_s(:iso8601)).to eql(val.to_formatted_s(:iso8601))
      end
    end

    describe '#find_by_identifier(provenance:, json:)' do
      it 'returns nil if json is not present' do
        expect(described_class.send(:find_by_identifier, provenance: @provenance, json: {})).to eql(nil)
      end
      it 'returns nil if :dmp_id are not present' do
        @json.delete(:dmp_id)
        expect(described_class.send(:find_by_identifier, provenance: @provenance, json: @json)).to eql(nil)
      end
      it 'finds the DataManagementPlan by :dmp_id' do
        id = @dmp.identifiers.select { |i| i.descriptor == 'is_identified_by' }.first
        @json[:dmp_id] = { type: id.category, identifier: id.value }
        result = described_class.send(:find_by_identifier, provenance: @provenance, json: @json)
        expect(result).to eql(@dmp)
      end
    end

    describe '#find_by_contact_and_title(provenance:, contact:, json:)' do
      it 'returns an existing DataManagementPlan record' do
        @json[:title] = @dmp.title
        result = described_class.send(:find_by_contact_and_title, provenance: @provenance,
                                                                  contact: @dmp.primary_contact, json: @json)
        expect(result).to eql(@dmp)
      end
      it 'initializes a DataManagementPlan record' do
        result = described_class.send(:find_by_contact_and_title, provenance: @provenance,
                                                                  contact: @dmp.primary_contact, json: @json)
        expect(result.new_record?).to eql(true)
        expect(result.title).to eql(@json[:title])
        expect(result.provenance).to eql(@provenance)
        expect(result.identifiers.last.category).to eql(@json[:dmp_id][:type])
        expect(result.identifiers.last.value).to eql(@json[:dmp_id][:identifier])
      end
    end

    describe '#attach_identifier(provenance:, dmp:, json:)' do
      it 'returns the DataManagementPlan as-is if json is not present' do
        result = described_class.send(:attach_identifier, provenance: @provenance, dmp: @dmp, json: {})
        expect(result.identifiers).to eql(@dmp.identifiers)
      end
      it 'returns the DataManagementPlan as-is if :dmp_id is not present' do
        @json.delete(:dmp_id)
        result = described_class.send(:attach_identifier, provenance: @provenance, dmp: @dmp, json: @json)
        expect(result.identifiers).to eql(@dmp.identifiers)
      end
      it 'initializes the identifier and adds it to the DataManagementPlan' do
        result = described_class.send(:attach_identifier, provenance: @provenance,
                                                          dmp: build(:data_management_plan), json: @json)
        expect(result.identifiers.length).to eql(1)
        expect(result.identifiers.last.category).to eql(@json[:dmp_id][:type])
        expect(result.identifiers.last.value).to eql(@json[:dmp_id][:identifier])
      end
    end

    describe '#deserialize_projects(provenance:, dmp:, json: {})' do
      it 'returns the DataManagementPlan as-is if provenance is not present' do
        result = described_class.send(:deserialize_projects, provenance: nil, dmp: @dmp, json: @json)
        expect(result.project).to eql(@dmp.project)
      end
      it 'returns nil if dmp is not present' do
        result = described_class.send(:deserialize_projects, provenance: @provenance, dmp: nil, json: @json)
        expect(result).to eql(nil)
      end
      it 'returns the DataManagementPlan as-is if json is not present' do
        result = described_class.send(:deserialize_projects, provenance: @provenance, dmp: @dmp, json: nil)
        expect(result.project).to eql(@dmp.project)
      end
      it 'returns the DataManagementPlan as-is if it already has a :project' do
        result = described_class.send(:deserialize_projects, provenance: @provenance, dmp: @dmp, json: nil)
        expect(result.project).to eql(@dmp.project)
      end
      it 'adds the Project to the DataManagementPlan if it does not have one' do
        result = described_class.send(:deserialize_projects, provenance: @provenance,
                                                             dmp: build(:data_management_plan), json: @json)
        expect(result.project.new_record?).to eql(true)
        expect(result.project.title).to eql(@json[:project].first[:title])
      end
      it 'adds a default Project if none was supplied and this is a new DataManagementPlan' do
        @json.delete(:project)
        result = described_class.send(:deserialize_projects, provenance: @provenance,
                                                             dmp: build(:data_management_plan), json: @json)
        expect(result.project.new_record?).to eql(true)
        expect(result.project.title.starts_with?('Project: ')).to eql(true)
      end
      it 'adds a default Project to the existing DataManagementPlan' do
        @json.delete(:project)
        result = described_class.send(:deserialize_projects, provenance: @provenance, dmp: @dmp, json: @json)
        expect(result.project.new_record?).to eql(true)
        expect(result.project.title).to eql("Project: #{@dmp.title}")
      end
    end

    describe '#deserialize_contact(provenance:, dmp:, json: {})' do
      it 'returns the DataManagementPlan as-is if provenance is not present' do
        result = described_class.send(:deserialize_contact, provenance: nil, dmp: @dmp, json: @json)
        expect(result.project).to eql(@dmp.project)
      end
      it 'returns nil if dmp is not present' do
        result = described_class.send(:deserialize_contact, provenance: @provenance, dmp: nil, json: @json)
        expect(result).to eql(nil)
      end
      it 'returns the DataManagementPlan as-is if json is not present' do
        result = described_class.send(:deserialize_contact, provenance: @provenance, dmp: @dmp, json: nil)
        expect(result.project).to eql(@dmp.project)
      end
      it 'Replaces the Primary Contact' do
        result = described_class.send(:deserialize_contact, provenance: @provenance, dmp: @dmp, json: @json)

        cdmp = result.contributors_data_management_plans.select { |c| c.role == 'primary_contact' }.first
        expect(cdmp.contributor.name).to eql(@json[:contact][:name])
        expect(cdmp.role).to eql('primary_contact')
      end
      it 'adds the Primary Contact if its a new DataManagementPlan' do
        result = described_class.send(:deserialize_contact, provenance: @provenance,
                                                            dmp: build(:data_management_plan), json: @json)
        cdmp = result.contributors_data_management_plans.select { |c| c.role == 'primary_contact' }.first
        expect(cdmp.contributor.name).to eql(@json[:contact][:name])
        expect(cdmp.role).to eql('primary_contact')
      end
    end

    describe '#deserialize_contributors(provenance:, dmp:, json: {})' do
      before(:each) do
        @contact = @dmp.primary_contact
        @json[:contact] = { name: @contact.name, mbox: @contact.email }
        @old_cdmp = @dmp.contributors_data_management_plans.last
      end
      it 'returns the DataManagementPlan as-is if provenance is not present' do
        result = described_class.send(:deserialize_contributors, provenance: nil, dmp: @dmp, json: @json)
        expect(result.project).to eql(@dmp.project)
      end
      it 'returns nil if dmp is not present' do
        result = described_class.send(:deserialize_contributors, provenance: @provenance, dmp: nil, json: @json)
        expect(result).to eql(nil)
      end
      it 'returns the DataManagementPlan as-is if json is not present' do
        result = described_class.send(:deserialize_contributors, provenance: @provenance, dmp: @dmp, json: nil)
        expect(result.project).to eql(@dmp.project)
      end
      it 'adds the Contributor to a new DataManagementPlan' do
        result = described_class.send(:deserialize_contributors, provenance: @provenance,
                                                                 dmp: build(:data_management_plan), json: @json)
        cdmps = result.contributors_data_management_plans
        expect(cdmps.length).to eql(@json[:contributor].length + 1)
        cdmps.each do |cdmp|
          if cdmp.role == 'primary_contact'
            expect(cdmp.contributor.email).to eql(@json[:contact][:mbox])
          else
            expect(@json[:contributor].map { |c| c[:mbox] }.include?(cdmp.contributor.email)).to eql(true)
          end
        end
      end
      it 'adds the Contributor to an existing DataManagementPlan' do
        @dmp.contributors_data_management_plans.each do |cdmp|
          # Skip the contact role here. It is covered above in the :before
          next if cdmp.role == 'primary_contact'

          @json[:contributor] << {
            name: cdmp.contributor.name,
            mbox: cdmp.contributor.email,
            role: [cdmp.role]
          }
        end

        result = described_class.send(:deserialize_contributors, provenance: @provenance, dmp: @dmp, json: @json)
        expect(result.contributors.length).to eql(@json[:contributor].length + 1)
        @json[:contributor].each do |contrib|
          cdmp = result.contributors_data_management_plans.select { |c| c.contributor.email == contrib[:mbox] }.first
          expect(cdmp.contributor.name).to eql(contrib[:name])
          expect(cdmp.role).to eql(contrib[:role].first)
        end
      end
      it 'adds a new role to an existing Contributor' do
        old_cdmp = @dmp.contributors_data_management_plans.last
        roles = ContributorsDataManagementPlan.roles.keys.reject do |role|
          [old_cdmp.role, 'primary_contact'].include?(role)
        end
        new_role = roles.sample
        @json[:contributor] = [{
          name: Faker::Movies::StarWars.character,
          mbox: @dmp.contributors_data_management_plans.last.contributor.email,
          role: [old_cdmp.role, new_role]
        }]
        result = described_class.send(:deserialize_contributors, provenance: @provenance, dmp: @dmp, json: @json)

        cdmps = result.contributors_data_management_plans.select { |cdmp| cdmp.contributor == old_cdmp.contributor }
        expect(cdmps.length).to eql(2)
        expect(cdmps.map(&:role).include?(old_cdmp.role)).to eql(true)
        expect(cdmps.map(&:role).include?(new_role)).to eql(true)
      end
      it 'removes a role from an existing Contributor' do
        old_cdmp = @dmp.contributors_data_management_plans.last
        roles = ContributorsDataManagementPlan.roles.keys.reject do |role|
          [old_cdmp.role, 'primary_contact'].include?(role)
        end
        new_role = roles.sample
        @json[:contributor] = [{
          name: Faker::Movies::StarWars.character,
          mbox: @dmp.contributors_data_management_plans.last.contributor.email,
          role: [new_role]
        }]
        result = described_class.send(:deserialize_contributors, provenance: @provenance, dmp: @dmp, json: @json)

        cdmps = result.contributors_data_management_plans.select { |cdmp| cdmp.contributor == old_cdmp.contributor }
        expect(cdmps.length).to eql(1)
        expect(cdmps.map(&:role).include?(old_cdmp.role)).to eql(false)
        expect(cdmps.map(&:role).include?(new_role)).to eql(true)
      end
    end

    describe '#deserialize_costs(provenance:, dmp:, json: {})' do
      it 'returns the DataManagementPlan as-is if provenance is not present' do
        result = described_class.send(:deserialize_costs, provenance: nil, dmp: @dmp, json: @json)
        expect(result.costs).to eql(@dmp.costs)
      end
      it 'returns nil if dmp is not present' do
        result = described_class.send(:deserialize_costs, provenance: @provenance, dmp: nil, json: @json)
        expect(result).to eql(nil)
      end
      it 'returns the DataManagementPlan as-is if json is not present' do
        result = described_class.send(:deserialize_costs, provenance: @provenance, dmp: @dmp, json: nil)
        expect(result.costs).to eql(@dmp.costs)
      end
      it 'returns the DataManagementPlan as-is if it already has a :cost' do
        result = described_class.send(:deserialize_costs, provenance: @provenance, dmp: @dmp, json: nil)
        expect(result.costs).to eql(@dmp.costs)
      end
      it 'adds the Cost to the DataManagementPlan' do
        result = described_class.send(:deserialize_costs, provenance: @provenance, dmp: @dmp, json: @json)
        expect(result.costs.map(&:title).include?(@json[:cost].first[:title])).to eql(true)
      end
      it 'adds the Cost to a new DataManagementPlan' do
        result = described_class.send(:deserialize_costs, provenance: @provenance,
                                                          dmp: build(:data_management_plan), json: @json)
        expect(result.costs.map(&:title).include?(@json[:cost].first[:title])).to eql(true)
      end
      it 'removes the Cost from the DataManagementPlan if it is not in the json' do
        result = described_class.send(:deserialize_costs, provenance: @provenance, dmp: @dmp, json: @json)
        expect(result.costs.map(&:title).include?(@dmp.costs.first.title)).to eql(true)
      end
    end

    describe '#deserialize_datasets(provenance:, dmp:, json: {})' do
      it 'returns the DataManagementPlan as-is if provenance is not present' do
        result = described_class.send(:deserialize_datasets, provenance: nil, dmp: @dmp, json: @json)
        expect(result.datasets).to eql(@dmp.datasets)
      end
      it 'returns nil if dmp is not present' do
        result = described_class.send(:deserialize_datasets, provenance: @provenance, dmp: nil, json: @json)
        expect(result).to eql(nil)
      end
      it 'returns the DataManagementPlan as-is if json is not present' do
        result = described_class.send(:deserialize_datasets, provenance: @provenance, dmp: @dmp, json: nil)
        expect(result.datasets).to eql(@dmp.datasets)
      end
      it 'returns the DataManagementPlan as-is if it already has a :cost' do
        result = described_class.send(:deserialize_datasets, provenance: @provenance, dmp: @dmp, json: nil)
        expect(result.datasets).to eql(@dmp.datasets)
      end
      it 'adds the Dataset to the DataManagementPlan' do
        result = described_class.send(:deserialize_datasets, provenance: @provenance, dmp: @dmp, json: @json)
        expect(result.datasets.map(&:title).include?(@json[:dataset].first[:title])).to eql(true)
      end
      it 'adds the Dataset to a new DataManagementPlan' do
        result = described_class.send(:deserialize_datasets, provenance: @provenance,
                                                             dmp: build(:data_management_plan), json: @json)
        expect(result.datasets.map(&:title).include?(@json[:dataset].first[:title])).to eql(true)
      end
      it 'removes the Dataset from the DataManagementPlan if it is not in the json' do
        result = described_class.send(:deserialize_datasets, provenance: @provenance, dmp: @dmp, json: @json)
        expect(result.datasets.map(&:title).include?(@dmp.datasets.first.title)).to eql(true)
      end
      it 'adds a default Dataset if none was supplied and this is a new DataManagementPlan' do
        @json.delete(:dataset)
        result = described_class.send(:deserialize_datasets, provenance: @provenance,
                                                             dmp: build(:data_management_plan), json: @json)
        expect(result.datasets.first.new_record?).to eql(true)
        expect(result.datasets.first.title.starts_with?('Dataset for: ')).to eql(true)
        expect(result.datasets.first.dataset_type).to eql('dataset')
      end
      it 'adds a default Dataset to the existing DataManagementPlan' do
        @json.delete(:dataset)
        @dmp.datasets.destroy_all
        result = described_class.send(:deserialize_datasets, provenance: @provenance, dmp: @dmp, json: @json)
        expect(result.datasets.first.title).to eql("Dataset for: #{@dmp.title}")
        expect(result.datasets.first.dataset_type).to eql('dataset')
      end
    end

    describe '#deserialize_related_identifiers(provenance:, dmp:, json:)' do
      it 'returns the DataManagementPlan as-is if provenance is not present' do
        result = described_class.send(:deserialize_related_identifiers, provenance: nil, dmp: @dmp, json: @json)
        expect(result.identifiers).to eql(@dmp.identifiers)
      end
      it 'returns nil if dmp is not present' do
        result = described_class.send(:deserialize_related_identifiers, provenance: @provenance, dmp: nil, json: @json)
        expect(result).to eql(nil)
      end
      it 'returns the DataManagementPlan as-is if json is not present' do
        result = described_class.send(:deserialize_related_identifiers, provenance: @provenance, dmp: @dmp, json: nil)
        expect(result.identifiers).to eql(@dmp.identifiers)
      end
      it 'returns the DataManagementPlan as-is if it already has a :cost' do
        result = described_class.send(:deserialize_related_identifiers, provenance: @provenance, dmp: @dmp, json: nil)
        expect(result.identifiers).to eql(@dmp.identifiers)
      end
      it 'retains the is_identifier_by and is_metadata_for identifiers!' do
        @json.delete(:dmproadmap_related_identifiers)
        result = described_class.send(:deserialize_related_identifiers, provenance: @provenance, dmp: @dmp, json: @json)
        expect(result.identifiers).to eql(@dmp.identifiers)
      end
      it 'adds the RelatedIdentifier to the DataManagementPlan' do
        @dmp.identifiers.each do |id|
          next if %w[is_identified_by is_metadata_for].include?(id.descriptor)

          @json[:dmproadmap_related_identifiers] << {
            type: id.category, descriptor: id.descriptor, identifier: id.value
          }
        end
        count = @dmp.identifiers.length
        result = described_class.send(:deserialize_related_identifiers, provenance: @provenance, dmp: @dmp, json: @json)

        expect(result.identifiers.length).to eql(count + 1)
        expected = @json[:dmproadmap_related_identifiers].last
        expect(result.identifiers.last.category).to eql(expected[:type])
        expect(result.identifiers.last.descriptor).to eql(expected[:descriptor])
        expect(result.identifiers.last.value).to eql(expected[:identifier])
      end
      it 'adds the RelatedIdentifier to a new DataManagementPlan' do
        result = described_class.send(:deserialize_related_identifiers, provenance: @provenance,
                                                                        dmp: build(:data_management_plan), json: @json)
        expected = @json[:dmproadmap_related_identifiers].last
        expect(result.identifiers.last.category).to eql(expected[:type])
        expect(result.identifiers.last.descriptor).to eql(expected[:descriptor])
        expect(result.identifiers.last.value).to eql(expected[:identifier])
      end
      it 'removes the RelatedIdentifier from the DataManagementPlan if it is not in the json' do
        related = create(:identifier, identifiable: @dmp, descriptor: 'is_referenced_by')
        @dmp.reload
        count = @dmp.identifiers.length
        result = described_class.send(:deserialize_related_identifiers, provenance: @provenance, dmp: @dmp, json: @json)

        expect(result.identifiers.length).to eql(count - 1)
        expect(result.identifiers.map(&:value).include?(related.value)).not_to eql(true)
      end
    end
  end
end
