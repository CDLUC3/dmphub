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
          #           "relation_type": "is_referenced_by",
          #           "related_identifier_type": "DOI",
          #           "value": "http://doi.org/10.123/12345.aBc"
          #         }
          #       ]
          #     }
          #   }
          def deserialize(provenance:, json: {})
            return nil unless provenance.present? && valid?(json: json)

            # First attempt to look the DMP up by its identifier
            dmp = find_by_identifier(provenance: provenance, json: json)

            # Get the Contact
            contact = Api::V0::Deserialization::Contributor.deserialize(
              provenance: provenance, json: json[:contact], is_contact: true
            )

            # Find of Initialize the DMP by the title and Contact if it was not found by ID
            dmp = find_by_contact_and_title(provenance: provenance, contact: contact, json: json) unless dmp.present?

            # Update the contents of the DMP
            dmp.primary_contact = contact
            dmp.description = json[:description]
            dmp.language = Api::V0::ConversionService.language(code: json[:language])
            dmp.ethical_issues = Api::V0::ConversionService.yes_no_unknown_to_boolean(json[:ethical_issues_exist])
            dmp.ethical_issues_report = json[:ethical_issues_report]
            dmp.ethical_issues_description = json[:ethical_issues_description]

            dmp = deserialize_projects(provenance: provenance, dmp: dmp, json: json)
            dmp = deserialize_contributors(provenance: provenance, dmp: dmp, json: json)
            dmp = deserialize_costs(provenance: provenance, dmp: dmp, json: json)
            dmp = deserialize_datasets(provenance: provenance, dmp: dmp, json: json)
            deserialize_related_identifiers(provenance: provenance, dmp: dmp, json: json)
          end

          private

          # The JSON is valid if the DMP has a title, ID and Contact
          def valid?(json: {})
            json.present? &&
              json[:title].present? &&
              json[:dmp_id].present? && json[:dmp_id][:identifier].present? &&
              json[:contact].present? # && json[:contact][:mbox].present?
          end

          # Locate the DMP by its identifier
          def find_by_identifier(provenance:, json: {})
            id_json = json.fetch(:dmp_id, {})
            return nil unless id_json[:identifier].present?

            id = Api::V0::Deserialization::Identifier.deserialize(provenance: provenance,
                                                                  identifiable: nil,
                                                                  json: id_json)
            id.present? && id.identifiable.is_a?(DataManagementPlan) ? id.identifiable : nil
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
              provenance: provenance, identifiable: dmp, json: id, descriptor: descriptor
            )
            dmp.identifiers << identifier if identifier.present? && identifier.new_record?
            dmp
          end

          # Deserialize the Project information and attach to DMP
          def deserialize_projects(provenance:, dmp:, json: {})
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
            dmp.project = project.present? ? project : default_project(provenance: provenance, dmp: dmp)
            dmp
          end

          # Deserialize the Contributor information and attach to DMP
          def deserialize_contributors(provenance:, dmp:, json: {})
            json.fetch(:contributor, []).each do |contributor_json|
              contributor = Api::V0::Deserialization::Contributor.deserialize(
                provenance: provenance, json: contributor_json
              )

              contributor_json.fetch(:role, []).map do |role|
                url = role.starts_with?('http') ? role : Api::V0::ConversionService.to_credit_taxonomy(role: role)
                next unless url.present?

                cdmp = ContributorsDataManagementPlan.find_or_initialize_by(
                  data_management_plan: dmp, contributor: contributor,
                  provenance: provenance, role: role
                )
                next unless cdmp.present?

                dmp.contributors_data_management_plans << cdmp
              end
            end
            dmp
          end

          # Deserialize the Cost information and attach to DMP
          def deserialize_costs(provenance:, dmp:, json: {})
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
            json.fetch(:dataset, []).each do |dataset_json|
              dataset = Api::V0::Deserialization::Dataset.deserialize(
                provenance: provenance, dmp: dmp, json: dataset_json
              )
              dmp.datasets << dataset if dataset.present?
            end
            dmp.datasets << default_dataset(provenance: provenance, dmp: dmp) unless dmp.datasets.any?
            dmp
          end

          # Deserialize any relatedIdentifiers that were passed in
          def deserialize_related_identifiers(provenance:, dmp:, json:)
            return dmp unless provenance.present? && json.fetch(:dmproadmap_related_identifiers, []).any?

            json[:dmproadmap_related_identifiers].each do |related|
              related[:type] = Api::V0::ConversionService.identifier_category_from_value(value: related[:identifier])

              identifier = Api::V0::Deserialization::Identifier.deserialize(
                provenance: provenance, identifiable: dmp, descriptor: related[:relation_type], json: related
              )
              next unless identifier.present?
              dmp.identifiers << identifier unless dmp.identifiers.include?(identifier)
            end
            dmp
          end

          # Generate a default project
          def default_project(provenance:, dmp:)
            return nil unless provenance.present? && dmp.present?

            ::Project.new(
              provenance: provenance,
              title: "Project: #{dmp.title}",
              start_on: Time.now,
              end_on: (Time.now + 2.years)
            )
          end

          # Generate a default dataset
          def default_dataset(provenance:, dmp:)
            return nil unless provenance.present? && dmp.present?

            ::Dataset.new(title: "Dataset for: #{dmp.title}", dataset_type: 'dataset', provenance: provenance)
          end
        end
        # rubocop:enable Metrics/ClassLength
      end
    end
  end
end
