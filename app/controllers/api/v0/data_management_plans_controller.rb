# frozen_string_literal: true

module Api
  module V0
    # Controller providing DMP functionality
    # rubocop:disable Metrics/ClassLength
    class DataManagementPlansController < BaseApiController
      protect_from_forgery with: :null_session, only: [:create]

      before_action :base_response_content
      before_action :doi_param_to_dmp, only: %w[show update delete]

      def index
        dmp_ids = ApiClientAuthorization.by_api_client_and_type(
          api_client_id: client[:id],
          authorizable_type: 'DataManagementPlan'
        ).pluck(:authorizable_id)

        @payload = { items: DataManagementPlan.where(id: dmp_ids) }
      end

      # GET /data_management_plans/:id
      def show
        if authorized?
          @source = "GET #{api_v0_data_management_plan_url(id: params[:id])}"
        else
          render_error(errors: [], status: :not_found)
        end
      end

      # POST /data_management_plans
      # rubocop:disable Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity
      # rubocop:disable Metrics/MethodLength
      def create
        # Only proceed if the Application has permission
        if permitted?
          @dmp = Api::V0::Deserialization::DataManagementPlan.deserialize(
            provenance: provenance, json: dmp_params.to_h.with_indifferent_access
          )

          if @dmp.present?
            if @dmp.new_record?
              # rubocop:disable Metrics/BlockNesting
              @dmp = PersistenceService.process_full_data_management_plan(
                client: client,
                dmp: @dmp,
                history_description: "#{request.method} #{request.url}",
                mintable: true
              )

              if @dmp.dois.any? || @dmp.arks.any?
                render 'show', status: :created
              else
                render_error errors: ['Unable to acquire a DOI at this time. Please try your request later.'],
                             status: 500
              end
              # rubocop:enable Metrics/BlockNesting
            else
              doi = @dmp.dois.last || @dmp.urls.last
              msg = 'DMP already exists try sending an update to the attached :dmp_id instead'
              render_error errors: [msg], status: :method_not_allowed, items: [doi]
            end
          elsif provenance.present?
            log_error(error: 'Create failed - invalid JSON received and DMP could not be deserialized.')
            # TODO: We may want to comment this out for Prod
            log_error(error: dmp_params.to_h)
            msg = 'You must include at least a :title, :contact (with :name) and :dmp_id (with :identifier)'
            render_error errors: ["Invalid JSON format - #{msg}"], status: :bad_request
          else
            log_error(error: "Create failed - provenance is missing! CLIENT: '#{client&.name}'")
            msg = 'The :dmp must include a :title, { dmp_id: :identifier } and { contact: :name }'
            render_error errors: ["Invalid JSON format - #{msg}"], status: :bad_request
          end
        else
          render_error errors: 'Unauthorized', status: :unauthorized
        end
      rescue ActionController::ParameterMissing => e
        render_error errors: "Invalid json format (#{e.message})", status: :bad_request
      rescue StandardError => e
        log_error(error: e)
        render_error errors: [e.message], status: :bad_request
      end
      # rubocop:enable Metrics/MethodLength
      # rubocop:enable Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity

      private

      def dmp_params
        params.require(:dmp).permit(plan_permitted_params)
      end

      # Convert the incoming DOI/ARK/URL into a DMP
      def doi_param_to_dmp
        case params[:id][0..3]
        when 'doi:'
          @dmp = Identifier.where('value LIKE ?', "%#{params[:id].gsub('doi:', '')}")
                           .where(category: 'doi', descriptor: 'is_identified_by')
                           .first&.identifiable
        when 'ark:'
          @dmp = Identifier.where('value LIKE ?', "%#{params[:id].gsub('ark:', '')}")
                           .where(category: 'ark', descriptor: 'is_identified_by')
                           .first&.identifiable
        when 'url:'
          # Allows for retrieving the record by the associated object's URL
          @dmp = Identifier.where('value LIKE ?', "%#{params[:id].gsub('url', '')}")
                           .where(category: 'url', descriptor: 'is_metadata_for')
                           .first&.identifiable
        end
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

    end
    # rubocop:enable Metrics/ClassLength
  end
end
