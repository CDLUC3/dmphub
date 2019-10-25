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
        @source = "GET #{api_v0_awards_url}"
        award_ids = current_client[:profile].authorized_entities(entity_clazz: Award)
        # TODO: figure out paging here so we're not sedning back large JSON
        join_hash = {
          project: {
            data_management_plans: {
              person_data_management_plans: {
                person: { person_organizations: :organization }
              }
            }
          }
        }
        @awards = Award.joins(join_hash).includes(join_hash)
        @status = :ok
      end

      # PUT /awards/:id
      def update
        @source = "POST #{api_v0_award_url(id: params[:id])}"

        award_permitted_params
      end

      private

      def authorize_award_assertions
        current_client[:profile].award_assertion?
      end
    end
  end
end
