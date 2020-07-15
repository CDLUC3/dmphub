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
        if authorized?
          @source = "GET #{api_v0_data_management_plan_url(@dmp.dois.first.value)}"
        else
          render_error(errors: [], status: :not_found)
        end

        #render 'show'
      end

      # POST /data_management_plans
      # rubocop:disable Metrics/MethodLength
      def create
        # Only proceed if the Application has permission
        if permitted?
          provenance = Provenance.by_api_client(api_client: client)
          @dmp = Api::V0::Deserialization::DataManagementPlan.deserialize(
            provenance: provenance, json: dmp_params.to_h
          )

p @dmp.inspect

          if @dmp.present?

          else
            msg = 'You must include at least a :title, :contact (with :mbox) and :dmp_id (with :identifier)'
            render_error errors: "Invalid JSON format - #{msg}", status: :bad_request
          end

=begin
          # TODO: Determine how to handle multiple projects
          project = Project.from_json!(provenance:  client.name, json: dmp_params[:project].first)
          errs = model_errors(model: project)
          render_error errors: errs, status: :unprocessable_entity if errs.any?

          @dmp = DataManagementPlan.from_json!(json: dmp_params, provenance:  client.name)
          if @dmp.present?
            # rubocop: disable Metrics/BlockNesting
            if @dmp.project.save
              # Mint the DOI if we did not recieve a DOI in the input
              @dmp.mint_doi(provenance:  client.name) if @dmp.present? && @dmp.new_record?

              if @dmp.save
                setup_authorizations(dmp: @dmp)
                head :created, location: landing_page_url(id: @dmp.dois.first&.value)
              else
                # rollback(dmp: @dmp)
                errs = @dmp.project.errors
                @dmp.project.destroy
                Rails.logger.warn "Error saving DMP during api/v0/data_management_plans#create: #{errs}"
                render_error errors: errs, status: :unprocessable_entity
              end
            else
              errs = @dmp.project.errors
              Rails.logger.warn "Error saving Project during api/v0/data_management_plans#create: #{errs}"
              render_error errors: "Unable to register your DMP: #{errs}", status: :unprocessable_entity
            end
            # rubocop: enable Metrics/BlockNesting
          else
            render_error errors: 'Invalid json format', status: :bad_request
          end
=end

        else
          render_error errors: 'Unauthorized', status: :unauthorized
        end
      rescue ActionController::ParameterMissing => e
        render_error errors: "Invalid json format (#{e.message})", status: :bad_request
      end
      # rubocop:enable Metrics/MethodLength

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
        @dmp.present? && @client.present? && @dmp.authorized?(api_client: @client)
      end
    end
  end
end
