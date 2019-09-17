# frozen_string_literal: true

# See below for an example of the JSON output

module Api
  module V1
    # Controller providing DMP functionality
    class DataManagementPlansController < BaseApiController

      protect_from_forgery with: :null_session, only: [:create]

      before_action :load_dmp, except: %i[index create]

      PARTIAL = 'api/v1/rd_common_standard/data_management_plans_show.json.jbuilder'.freeze

      # GET /data_management_plans
      def index
        dmps = DataManagementPlan.by_client(client_id: current_client[:id]).order(updated_at: :desc)
        render 'index', locals: {
          data_management_plans: dmps,
          caller: current_client[:name],
          source: "GET #{api_v1_data_management_plans_url}"
        }
      end

      # GET /data_management_plans/:id
      def show
        render(json: empty_response, status: :not_found) unless authorized?
        render 'show', locals: {
          data_management_plan: @dmp,
          caller: current_client[:name],
          source: "GET #{api_v1_data_management_plan_url(@dmp)}"
        }
      end

      # POST /data_management_plans
      def create
        render json: empty_response, status: :bad_request unless params['dmp'].present?

        @dmp = DataManagementPlan.from_json(json: dmp_params,
                                            provenance: current_client[:name])
        render json: { errors: [{ dmp: 'invalid json' }] },
               status: :bad_request unless @dmp.present?

        if @dmp.save
          # Associate the DMP with the Client/Application who created it
          OauthAuthorization.create(oauth_application: doorkeeper_token.application, data_management_plan: @dmp)
          # Mint the DOI
          doi = DataciteService.mint_doi(data_management_plan: @dmp)
          @dmp.identifiers << Identifier.new(provenance: current_client[:name],
                                             category: 'doi', value: doi)
          @dmp.save

          render 'show', locals: {
            data_management_plan: @dmp,
            caller: current_client[:name],
            source: "POST #{api_v1_data_management_plans_url}"
          }, status: 201
        else
          render json: error_response(@dmp), status: :bad_request
        end
      end

      # PUT /data_management_plans/:id
      def update; end

      # DELETE /data_management_plans/:id
      def delete; end

      private

      def dmp_params
        params.require(:dmp).permit(
          RdaCommonStandardService.data_management_plan_permitted_params
          ).to_h
      end

      # Retrieve the specified DMP from the database and return a 404 if its either
      # not found or not owned by a client/application
      def load_dmp
        ident = Identifier.where(value: params[:id], identifiable_type: 'DataManagementPlan').first
        @dmp = DataManagementPlan.where(id: ident.identifiable_id).first if ident.present?

        render json: empty_response, status: :not_found unless authorized?
      end

      # Determine whether or not the client/application owns the DMP
      def authorized?
        return false unless @dmp.present? && current_client[:id].present?
        OauthAuthorization.where(data_management_plan_id: @dmp.id, oauth_application_id: current_client[:id]).any?
      end
    end
  end
end
