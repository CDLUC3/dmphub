# frozen_string_literal: true

module Api
  module V0
    # Controller providing DMP functionality
    class DataManagementPlansController < BaseApiController
      protect_from_forgery with: :null_session, only: [:create]

      before_action :base_response_content

      def index
        dmp_ids = ApiClientAuthorization.by_api_client_and_type(
          api_client_id: client[:id],
          authorizable_type: 'DataManagementPlan'
        ).pluck(:authorizable_id)

        @payload = { items: DataManagementPlan.where(id: dmp_ids) }
      end

      # GET /data_management_plans/:id
      def show
        @dmp = DataManagementPlan.find_by_doi(params[:id]).first
        @dmp = DataManagementPlan.where(id: params[:id]).first unless @dmp.present?

        if authorized?
          id = @dmp.dois.any? ? @dmp.dois.last : @dmp.id
          @source = "GET #{api_v0_data_management_plan_url(id)}"
        else
          render_error(errors: [], status: :not_found)
        end
      end

      # POST /data_management_plans
      # rubocop:disable Metrics/PerceivedComplexity
      def create
        # Only proceed if the Application has permission
        if permitted?
          @dmp = Api::V0::Deserialization::DataManagementPlan.deserialize(
            provenance: provenance, json: dmp_params.to_h.with_indifferent_access
          )

          if @dmp.present?
            if @dmp.new_record?
              process_dmp
              render 'ezid/minter.text.erb', layout: false, content_type: 'text/plain'
            else
              doi = @dmp.dois.last || @dmp.urls.last
              msg = "DMP already exists try sending an update instead using: {\"dmp_id\":{\"identifier\":\"#{doi.value}\"}"
              render_error errors: [msg], status: :bad_request
            end
          elsif provenance.present?
            msg = 'You must include at least a :title, :contact (with :mbox) and :dmp_id (with :identifier)'
            render_error errors: ["Invalid JSON format - #{msg}"], status: :bad_request
          else
            render_error errors: ['Unauthorized'], status: :unauthorized
          end
        else
          render_error errors: 'Unauthorized', status: :unauthorized
        end
      rescue ActionController::ParameterMissing => e
        render_error errors: "Invalid json format (#{e.message})", status: :bad_request
      end
      # rubocop:enable Metrics/PerceivedComplexity

      private

      def dmp_params
        params.require(:dmp).permit(plan_permitted_params)
      end

      def setup_authorizations(dmp:)
        return nil unless dmp.present? && dmp.is_a?(DataManagementPlan)

        # Associate the DMP with the Client/Application who created it
        Api::V0::Auth::Jwt::AuthorizationService.authorize!(dmp: dmp, entity: doorkeeper_token.application)
      end

      def retrieve_data_management_plan(download_url:)
        # TODO: if a downloadURL was provided, retrieve the file and then
        #       send it to the repository service for preservation
      end

      def permitted?
        return false unless client.present? && client.permissions.any?

        client.permissions.where(permission: 'data_management_plan_creation').any?
      end

      def authorized?
        @dmp.present? && client.present? && @dmp.authorized?(api_client: client)
      end

      # Determine what to render
      def process_dmp
        action = @dmp.new_record? ? 'add' : 'edit'
        @dmp.mint_doi(provenance: provenance) unless @dmp.dois.any?

        if @dmp.dois.empty? && @dmp.arks.empty?
          render_error errors: 'Unable to acquire a DOI at this time. Please try your request later.',
                       status: 500
        elsif @dmp.save
          ApiClientAuthorization.create(authorizable: @dmp, api_client: client)
          ApiClientHistory.create(api_client: client, data_management_plan: @dmp, change_type: action,
                                  description: "#{request.method} #{request.url}")
          @dmp = @dmp.reload
          render 'show', status: :created
        else
          render_error errors: @dmp.errors.full_messages, status: :bad_request
        end
      end
    end
  end
end
