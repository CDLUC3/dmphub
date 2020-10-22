# frozen_string_literal: true

module Api
  module V0
    module Deserialization
      # Converts incoming JSON into a Project
      class Project
        class << self
          # Convert the incoming JSON into a Project
          # {
          #   "title": "Brain impairment caused by COVID-19",
          #   "description": "Brain stem comparisons of COVID-19 patients",
          #   "start": "2020-03-01 12:33:44 UTC",
          #   "end": "2023-03-31 12:33:44 UTC",
          #   "funding": [{
          #     "$ref": "SEE Funding.deserialize! for details"
          #   }],
          #   "extension": [{
          #     "dmphub": {
          #       "project_id": {
          #         "type": "URL",
          #         "identifier": "https://some.school.edu/project/123"
          #       }
          #     }
          #   }]
          # }
          # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
          def deserialize(provenance:, dmp:, json: {})
            return nil unless provenance.present? && dmp.present? && valid?(json: json)

            # Find of Initialize the Project by the title and DMP
            project = find_by_dmp_and_title(provenance: provenance, dmp: dmp, json: json)
            return nil unless project.present?

            # Update the contents of the DMP
            project.description = json[:description]
            project.start_on = json[:start] if json[:start].present?
            project.end_on = json[:end] if json[:end].present?

            json.fetch(:funding, []).each do |funding_json|
              funding = Api::V0::Deserialization::Funding.deserialize(
                provenance: provenance, project: project, json: funding_json
              )
              project.fundings << funding if funding.present?
            end

            attach_identifier(provenance: provenance, project: project,
                              json: Api::V0::ConversionService.fetch_extension(json: json))
          end
          # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

          private

          # The JSON is valid if the Project has a title and start and end dates
          def valid?(json: {})
            json.present? && json[:title].present?
          end

          # Find the Project by its title and dmp
          def find_by_dmp_and_title(provenance:, dmp:, json: {})
            # Search the DB for the title
            project = ::Project.where('LOWER(title) = ?', json[:title].downcase)
                               .where(provenance: provenance).first
            return project if project.present? && dmp.project == project

            # If no good result was found just initialize a new one
            ::Project.new(provenance: provenance, title: json[:title])
          end

          # Marshal the Identifier and attach it
          def attach_identifier(provenance:, project:, json: {})
            id = json.fetch(:project_id, {})
            return project unless id[:identifier].present?

            identifier = Api::V0::Deserialization::Identifier.deserialize(
              provenance: provenance, identifiable: project, json: id
            )
            project.identifiers << identifier if identifier.present? && identifier.new_record?
            project
          end
        end
      end
    end
  end
end
