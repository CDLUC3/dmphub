# frozen_string_literal: true

module Api
  module V0
    # Controller providing DMP functionality
    class AwardsController < BaseApiController
      protect_from_forgery with: :null_session, only: [:create]

      before_action :base_response_content
      before_action :authorize_award_assertions

      # GET /awards
      def index
        award_ids = current_client[:profile].authorized_entities(entity_clazz: Award)
        join_hash = {
          project: {
            data_management_plans: {
              person_data_management_plans: {
                person: { person_organizations: :organization }
              }
            }
          }
        }
        @status = :ok
        @awards = paginate_response(results: Award.joins(join_hash).includes(join_hash))
      end

      # PUT /awards/:id
      def update
        # Expecting the following format:
        # {
        #   "dmp": {
        #     "dmpIds": [{
        #       'category': 'doi',
        #       'value': '10.234/erfere.234d'
        #     }],
        #     "dm_staff": [{
        #       "name": 'Jane Doe',
        #       "mbox": 'jane.doe@example.org',
        #       "contributor_type": 'program_officer',
        #       "organizations": [{
        #         "name": 'National Science Foundation (NSF)'
        #       }],
        #     }],
        #     "project": {
        #     "start_on": award[:project_start],
        #     "end_on": award[:project_end],
        #     "funding": [{
        #       "funder_id": 'http://dx.doi/path/to/funder',
        #       "grant_id": 'http://awards.example.org/1234',
        #       "funding_status": "granted",
        #       "award_ids": [
        #         'category': 'program',
        #         'value': 'Genomics'
        #       ]
        #     }]
        #   }
        # }
        # verify that `['funding']['funderId']` matches caller
        # verify that Award ID in `params[:id]` matches an award for the `dmpDOI`
        # verify that App has permission to make award assertions
        # verify that App has permission to make person assertions if they are present

        # Make assertions
        # Return proper status code and base response

        award_permitted_params
      end

      private

      def authorize_award_assertions
        current_client[:profile].award_assertion?
      end
    end
  end
end
