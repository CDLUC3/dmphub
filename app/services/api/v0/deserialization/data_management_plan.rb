# frozen_string_literal: true

module Api
  module V0
    module Deserialization
      # Converts the JSON into a DMP
      # rubocop:disable Metrics/ClassLength
      class DataManagementPlan
        class << self
          # Convert the incoming JSON into a Plan
          #   {
          #     "dmp": {
          #       "created": "2020-03-26T11:52:00Z",
          #       "modified": "2020-03-26T11:52:00Z",
          #       "title": "Brain impairment caused by COVID-19",
          #       "description": "DMP for COVID-19 Brain analysis",
          #       "language": "eng",
          #       "ethical_issues_exist": "yes",
          #       "ethical_issues_description": "We will need to anonymize data",
          #       "ethical_issues_report": "https://university.edu/ethics/policy.pdf",
          #       "contact": {
          #         "$ref": "SEE Contributor.deserialize! for details"
          #       },
          #       "dmp_id": {
          #         "type": "DOI",
          #         "identifier": "https://doix.org/10.1234/123ab.45c"
          #       },
          #       "contributor": [{
          #         "$ref": "SEE Contributor.deserialize! for details"
          #       }],
          #       "cost": [{
          #         "$ref": "SEE Cost.deserialize! for details"
          #       }],
          #       "project": [{
          #         "$ref": "SEE Project.deserialize! for details"
          #         }]
          #       }],
          #       "dataset": [{
          #         "$ref": "SEE Dataset.deserialize! for details"
          #       }],
          #       "dmproadmap_related_identifiers": [
          #         {
          #           "descriptor": "is_referenced_by",
          #           "type": "DOI",
          #           "identifier": "http://doi.org/10.123/12345.aBc"
          #         }
          #       ]
          #     }
          #   }
          def deserialize(provenance:, json: {}, original_dmp: nil)
            return nil unless provenance.present? && valid?(json: json)

            # If an original_dmp was specified then this is an update!
            dmp = original_dmp if original_dmp.present?

            # First attempt to look the DMP up by its identifier
            dmp = find_by_identifier(provenance: provenance, json: json) unless dmp.present?

            # Get the Contact
            contact = Api::V0::Deserialization::Contributor.deserialize(
              provenance: provenance, json: json[:contact], is_contact: true
            )

            # Find of Initialize the DMP by the title and Contact if it was not found by ID
            dmp = find_by_contact_and_title(provenance: provenance, contact: contact, json: json) unless dmp.present?

            # Update the contents of the DMP
            dmp.title = json[:title]
            dmp.version = get_version(value: json[:modified])
            dmp.description = json[:description]
            dmp.language = Api::V0::ConversionService.language(code: json[:language])
            dmp.ethical_issues = Api::V0::ConversionService.yes_no_unknown_to_boolean(json[:ethical_issues_exist])
            dmp.ethical_issues_report = json[:ethical_issues_report]
            dmp.ethical_issues_description = json[:ethical_issues_description]

            dmp.source_privacy = (json[:dmproadmap_privacy] == 'public' ? 'open' : 'closed')

            dmp = deserialize_projects(provenance: provenance, dmp: dmp, json: json)
            dmp = deserialize_contributors(provenance: provenance, dmp: dmp, json: json)
            dmp = deserialize_costs(provenance: provenance, dmp: dmp, json: json)
            dmp = deserialize_datasets(provenance: provenance, dmp: dmp, json: json)
            dmp = deserialize_download_link(provenance: provenance, dmp: dmp, json: json)
            dmp = deserialize_related_identifiers(provenance: provenance, dmp: dmp, json: json)
            deserialize_sponsors(provenance: provenance, dmp: dmp, json: json)
          end

          private

          # The JSON is valid if the DMP has a title, ID and Contact
          def valid?(json: {})
            json.present? &&
              json[:title].present? &&
              json[:dmp_id].present? && json[:dmp_id][:identifier].present? &&
              json[:contact].present? &&
              (json[:contact][:mbox].present? || json[:contact].fetch(:contact_id, {})[:identifier].present?)
          end

          # Convert the string into a Time or use the current Time if it fails
          def get_version(value: '')
            DateTime.parse(value.to_s)&.utc
          rescue ArgumentError
            Time.now.utc
          end

          # Locate the DMP by its identifier
          def find_by_identifier(provenance:, json: {})
            id_json = json.fetch(:dmp_id, {})
            return nil unless id_json[:identifier].present?

            id = Api::V0::Deserialization::Identifier.deserialize(provenance: provenance,
                                                                  identifiable: nil,
                                                                  identifiable_type: 'DataManagementPlan',
                                                                  json: id_json)
            id.present? && id.identifiable.is_a?(::DataManagementPlan) ? id.identifiable : nil
          end

          # Find the DMP by its title and contact
          def find_by_contact_and_title(provenance:, contact:, json: {})
            # Search the DB for the title
            dmp = ::DataManagementPlan.where('LOWER(title) = ?', json[:title].downcase).first
            return dmp if dmp.present? && dmp.primary_contact == contact

            # If no good result was found just initialize a new one
            dmp = ::DataManagementPlan.new(provenance: provenance, title: json[:title])
            attach_identifier(provenance: provenance, dmp: dmp, json: json)
          end

          # Marshal the Identifier and attach it
          def attach_identifier(provenance:, dmp:, json: {})
            id = json.fetch(:dmp_id, {})
            return dmp unless id[:identifier].present?

            descriptor = id[:type].downcase == 'url' ? 'is_metadata_for' : 'is_identified_by'
            identifier = Api::V0::Deserialization::Identifier.deserialize(
              provenance: provenance, identifiable: dmp, json: id, descriptor: descriptor,
              identifiable_type: 'DataManagementPlan'
            )
            dmp.identifiers << identifier if identifier.present? && identifier.new_record?
            dmp
          end

          # Deserialize the Project information and attach to DMP
          def deserialize_projects(provenance:, dmp:, json: {})
            return dmp unless provenance.present? && dmp.present? && json.present?

            # TODO: We can currently only handle one project, update to allow
            #       multiples unless the RDA Common Standard changes
            #
            # json.fetch(:project, []).each do |project_json|
            #   project = Api::V0::Deserialization::Project.deserialize(
            #     provenance: provenance, dmp: dmp, json: project_json
            #   )
            #   dmp.projects << project if project.present?
            # end
            project = Api::V0::Deserialization::Project.deserialize(
              provenance: provenance, dmp: dmp, json: json[:project]&.first
            )

            dmp.project = project.present? ? project : default_project(provenance: provenance, dmp: dmp, json: json)
            dmp
          end

          # Deserialize the Contact
          def deserialize_contact(provenance:, dmp:, json: {})
            return dmp unless provenance.present? && dmp.present? && json.present?

            # Remove the old contact (without Persisting the change yet!)
            dmp.contributors_data_management_plans = dmp.contributors_data_management_plans.reject do |cdmp|
              cdmp.role == 'primary_contact'
            end

            # Attach the Primary Contact
            contact = Api::V0::Deserialization::Contributor.deserialize(
              provenance: provenance, json: json[:contact], is_contact: true
            )

            if contact.present?
              cdmp = ::ContributorsDataManagementPlan.find_or_initialize_by(
                data_management_plan: dmp, contributor: contact,
                provenance: provenance, role: 'primary_contact'
              )
              dmp.contributors_data_management_plans << cdmp
            end
            dmp
          end

          # Deserialize the Contributor information and attach to DMP
          # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
          def deserialize_contributors(provenance:, dmp:, json: {})
            return dmp unless provenance.present? && dmp.present? && json.present?

            # Clear the old contributor and contact info
            dmp.contributors_data_management_plans.clear

            # Attach the Contributors and their roles
            json.fetch(:contributor, []).each do |contributor_json|
              contributor = Api::V0::Deserialization::Contributor.deserialize(
                provenance: provenance, json: contributor_json
              )

              contributor_json.fetch(:role, []).map do |role|
                url = role.starts_with?('http') ? role : Api::V0::ConversionService.to_credit_taxonomy(role: role)
                return nil unless url.present?

                cdmp = ContributorsDataManagementPlan.find_or_initialize_by(
                  data_management_plan: dmp, contributor: contributor,
                  provenance: provenance, role: role
                )
                dmp.contributors_data_management_plans << cdmp if cdmp.new_record?
              end
            end

            # Add the primary contact
            deserialize_contact(provenance: provenance, dmp: dmp, json: json)
            dmp
          end
          # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

          # Deserialize the Cost information and attach to DMP
          def deserialize_costs(provenance:, dmp:, json: {})
            return dmp unless provenance.present? && dmp.present? && json.present?

            dmp.costs.clear

            json.fetch(:cost, []).each do |cost_json|
              cost = Api::V0::Deserialization::Cost.deserialize(
                provenance: provenance, dmp: dmp, json: cost_json
              )
              dmp.costs << cost if cost.present?
            end
            dmp
          end

          # Deserialize the Dataset information and attach to DMP
          def deserialize_datasets(provenance:, dmp:, json: {})
            return dmp unless provenance.present? && dmp.present? && json.present?

            dmp.datasets.clear

            json.fetch(:dataset, []).each do |dataset_json|
              dataset = Api::V0::Deserialization::Dataset.deserialize(
                provenance: provenance, dmp: dmp, json: dataset_json
              )
              dmp.datasets << dataset if dataset.present?
            end
            dmp.datasets << default_dataset(provenance: provenance, dmp: dmp, json: json[:title]) unless dmp.datasets.any?
            dmp
          end

          # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
          def deserialize_download_link(provenance:, dmp:, json:)
            return dmp unless provenance.present? && json.present? && dmp.present?

            download_link = json.fetch('dmproadmap_links', {})['download']
            return dmp unless download_link.present?

            identifier = dmp.identifiers.select { |id| id.descriptor == 'is_metadata_for' }.last
            identifier.value = download_link if identifier.present?
            return dmp if identifier.present?

            identifier = Api::V0::Deserialization::Identifier.deserialize(
              provenance: provenance, identifiable: dmp, json: { type: 'url', identifier: download_link },
              descriptor: 'is_metadata_for', identifiable_type: 'DataManagementPlan'
            )
            dmp.identifiers << identifier if identifier.present? && identifier.new_record?
            dmp
          end
          # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

          # Deserialize any relatedIdentifiers that were passed in
          # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
          def deserialize_related_identifiers(provenance:, dmp:, json:)
            return dmp unless provenance.present? && json.present? && dmp.present?

            # Only retain the identifiers with loaded meaning
            #   is_identified_by -> One of the DMP's identifiers (e.g. ARK, DOI, etc.)
            #   is_metadata_for -> The location of the original DMP
            dmp.identifiers = dmp.identifiers.select do |id|
              %w[is_identified_by is_metadata_for].include?(id.descriptor)
            end

            json.fetch(:dmproadmap_related_identifiers, []).each do |related|
              related[:type] = Api::V0::ConversionService.identifier_category_from_value(value: related[:identifier]) unless related[:type].present?

              identifier = Api::V0::Deserialization::Identifier.deserialize(
                provenance: provenance, identifiable: dmp, identifiable_type: 'DataManagementPlan',
                descriptor: related[:descriptor], json: related
              )
              next unless identifier.present?

              dmp.identifiers << identifier unless dmp.identifiers.include?(identifier)
            end
            dmp
          end
          # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

          # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
          def deserialize_sponsors(provenance:, dmp:, json:)
            return dmp unless provenance.present? && json.present? && dmp.present?

            sponsors = json.fetch(:dmproadmap_sponsors, [])
            return dmp unless sponsors.any?

            sponsors.each do |hash|
              # First see if we already know about this sponsor
              if dmp.sponsors.any?
                matches = dmp.sponsors.select do |s|
                  s.name.downcase == hash[:name].downcase ||
                    (hash.fetch(:sponsor_id, {})[:identifier].present? &&
                     s.identifiers.select { |id| id.value.downcase == hash[:sponsor_id][:identifier].downcase })
                end
                next if matches.any?
              end

              # Initialize the sponsor and add it to the DMP
              sponsor = ::Sponsor.find_or_initialize_by(name: hash[:name], data_management_plan: dmp)
              sponsor.name_type = (hash[:type] == 'field_station' ? 'organizational' : 'personal')
              sponsor.provenance = provenance

              identifier = Api::V0::Deserialization::Identifier.deserialize(
                provenance: provenance, identifiable: sponsor, json: hash[:sponsor_id], identifiable_type: 'Sponsor'
              )
              sponsor.identifiers << identifier if identifier.present?

              dmp.sponsors << sponsor if sponsor.present? && sponsor.valid?
            end
            dmp
          end
          # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

          # Generate a default project
          def default_project(provenance:, dmp:, json:)
            return nil unless provenance.present? && dmp.present?

            ::Project.new(
              provenance: provenance,
              title: "Project: #{dmp.title || json[:title]}",
              start_on: Time.now,
              end_on: (Time.now + 2.years)
            )
          end

          # Generate a default dataset
          def default_dataset(provenance:, dmp:, json:)
            return nil unless provenance.present? && dmp.present?

            ::Dataset.new(
              title: "Dataset for: #{dmp.title || json[:title]}",
              dataset_type: 'dataset',
              provenance: provenance
            )
          end
        end
        # rubocop:enable Metrics/ClassLength
      end
    end
  end
end
