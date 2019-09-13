# frozen_string_literal: true

# See below for an example of the JSON output

module Api
  module V1
    # Controller providing DMP functionality
    class DataManagementPlansController < BaseApiController

      before_action :load_dmp, except: %i[index create]

      PARTIAL = 'api/v1/rd_common_standard/data_management_plans_show.json.jbuilder'.freeze

      # GET /data_management_plans
      def index
        dmps = DataManagementPlan.by_client(client_id: current_client[:uid])
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
      # not found or the client/application does not own it
      def load_dmp
        @dmp = DataManagementPlan.joins(oauth_authorization: :oauth_application)
          .includes(oauth_authorization: :oauth_application)
          .where(id: params[:id]).first

        render json: empty_response, status: :not_found unless authorized?
      end

      # Determine whether or not the client/application owns the DMP
      def authorized?
        @dmp.present? && @dmp.oauth_authorization.oauth_application.uid == current_client[:uid]
      end
    end
  end
end
