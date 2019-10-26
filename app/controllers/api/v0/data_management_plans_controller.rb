# frozen_string_literal: true

module Api
  module V0
    # Controller providing DMP functionality
    class DataManagementPlansController < BaseApiController
      protect_from_forgery with: :null_session, only: [:create]

      before_action :base_response_content

      # GET /data_management_plans/:id
      def show
        render(json: empty_response, status: :not_found) unless authorized?

        @source = "GET #{api_v0_data_management_plan_url(@dmp.doi.value)}"
        render 'show'
      end

      # POST /data_management_plans
      def create
        # Only proceed if the Application has permission too create
        if current_client[:profile].data_management_plan_creation?
          @dmp = DataManagementPlan.from_json(json: dmp_params, provenance: current_client[:name])

          if @dmp.present?
            if @dmp.project.save
              # Mint the DOI if we did not recieve a DOI in the input
              @dmp.mint_doi(provenance: current_client[:name]) if @dmp.present? && @dmp.new_record?

              if @dmp.save
                setup_authorizations(dmp: @dmp)
                render 'show', status: 201
              else
                rollback(dmp: @dmp)
                errs = (@dmp.errors.collect { |e, m| { "#{e}": m } } || []).join(', ')
                Rails.logger.warn "Error saving DMP during api/v0/create: #{errs}"
                render_error errors: (errs[:errors] << @errors), status: :unprocessable_entity
              end
            else
              errs = (@dmp.project.errors.collect { |e, m| { "#{e}": m } } || []).join(', ')
              Rails.logger.warn "Error saving Project during api/v0/create: #{errs}"
              render_error errors: "Unable to register your DMP: #{errs}", status: :unprocessable_entity
            end
          else
            render_error errors: 'Invalid json format', status: :bad_request
          end
        else
          render_error errors: 'Unauthorized', status: :unauthorized
        end
      rescue ActionController::ParameterMissing => pm
        render_error errors: "Invalid json format (#{pm.message})", status: :bad_request
      end

      private

      def dmp_params
        params.require(:dmp).permit(data_management_plan_permitted_params).to_h
      end

      def setup_authorizations(dmp:)
        return nil unless dmp.present? && dmp.is_a?(DataManagementPlan)

        # Associate the DMP with the Client/Application who created it
        Api::AuthorizationService.authorize!(dmp: dmp, entity: doorkeeper_token.application)
      end

      def retrieveDataManagementPlan(downloadUrl:)
        # TODO: if a downloadURL was provided, retrieve the file and then
        #       send it to the repository service for preservation
      end

    end
  end
end
