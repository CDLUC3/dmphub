# frozen_string_literal: true

# See below for an example of the JSON output

module Api
  module V1
    # Controller providing DMP functionality
    class DataManagementPlansController < BaseApiController

      before_action :load_dmp, except: %i[index]

      PARTIAL = 'api/v1/rd_common_standard/data_management_plans_show.json.jbuilder'.freeze

      # GET /data_management_plans
      def index
        dmps = DataManagementPlan.by_client(client_id: current_client[:uid])
        render 'index', locals: { data_management_plans: dmps }
      end

      # GET /data_management_plans/:id
      def show
        render(json: empty_response, status: :not_found) unless authorized?
        render 'show', locals: { data_management_plan: @dmp }
      end

      # POST /data_management_plans
      def create; end

      # PUT /data_management_plans/:id
      def update; end

      # DELETE /data_management_plans/:id
      def delete; end

      private

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
