# frozen_string_literal: true

module Api
  module V0
    # Controller providing DMP functionality
    class DataManagementPlansController < BaseApiController
      protect_from_forgery with: :null_session, only: [:create]

      before_action :base_response_content

      def index
        dmps = DataManagementPlan.joins(:authorizations).includes(:authorizations)
                                 .where(authorizations: { api_client_id:  client[:id] })
        @payload = { items: dmps }
      end

      # GET /data_management_plans/:id
      def show
        render_error(errors: [], status: :not_found) unless authorized?

        @source = "GET #{api_v0_data_management_plan_url(@dmp.dois.first.value)}"
        render 'show'
      end

      # POST /data_management_plans
      # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
      # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
      def create
        # Only proceed if the Application has permission
        if permitted?
          dmp = Api::V0::Deserialization::Plan.deserialize!(json: dmp_params)

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
      # rubocop:enable Metrics/MethodLength, Metrics/AbcSize
      # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

      private

      def dmp_params
        params.require(:dmp).permit(plan_permitted_params) #.to_h
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
        ApiClientPermission.data_management_plan_creation.map(&:api_client_id).include?(client.id)
      end

      def authorized?
        return false unless @dmp.present? && @client.present?

        @dmp.authorizations.map(&:api_client_id).include?(@client.id)
      end
    end
  end
end
