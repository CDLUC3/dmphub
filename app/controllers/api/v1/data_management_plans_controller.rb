# frozen_string_literal: true

# See below for an example of the JSON output

module Api
  module V1
    # Controller providing DMP functionality
    class DataManagementPlansController < BaseApiController
      protect_from_forgery with: :null_session, only: [:create]

      before_action :load_dmp, except: %i[index create]
      before_action :check_agent

      PARTIAL = 'api/v1/rd_common_standard/data_management_plans_show.json.jbuilder'

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
          source: "GET #{api_v1_data_management_plan_url(@doi.value)}"
        }
      end

      # POST /data_management_plans
      # rubocop:disable Metrics/CyclomaticComplexity
      # rubocop:disable Metrics/PerceivedComplexity
      def create
        @dmp = DataManagementPlan.from_json(json: dmp_params, provenance: current_client[:name])
        errors = { dmp: 'already exists' } if @dmp.present? && !@dmp.new_record?

        if errors.nil? && @dmp.present? && @dmp.save
          # Mint the DOI if we did not recieve a DOI in the input
          mint_doi!(dmp: @dmp)
          # Associate the DMP with the Client/Application who created it
          OauthAuthorization.find_or_create_by(
            oauth_application: doorkeeper_token.application,
            data_management_plan: @dmp
          )
          render_show dmp: @dmp
        else
          errs = { 'errors': (@dmp.errors.collect { |e, m| { "#{e}": m } } || []) }
          render_error errors: (errs[:errors] << errors)
        end
      rescue ActionController::ParameterMissing
        render_error errors: [{ dmp: 'invalid json format' }]
      end
      # rubocop:enable Metrics/CyclomaticComplexity
      # rubocop:enable Metrics/PerceivedComplexity

      # PUT /data_management_plans/:id
      def update; end

      # DELETE /data_management_plans/:id
      def delete; end

      private

      def render_show(dmp:)
        render 'show', locals: {
          data_management_plan: dmp,
          caller: current_client[:name],
          source: "POST #{api_v1_data_management_plans_url}"
        }, status: 201
      end

      def render_error(errors:)
        render 'error', locals: {
          caller: current_client[:name],
          source: "POST #{api_v1_data_management_plans_url}",
          errors: errors
        }, status: :bad_request
      end

      def mint_doi!(dmp:)
        existing = dmp.identifiers.select(&:doi?).any?
        return dmp if existing

        doi = DataciteService.mint_doi(data_management_plan: dmp,
                                       provenance: current_client[:name])
        render_error errors: [{ dmp: 'unable to register a DOI at this time' }] unless doi.present?

        dmp.identifiers << Identifier.new(provenance: 'datacite', category: 'doi', value: doi)
        dmp.save
      end

      def dmp_params
        params.require(:dmp).permit(
          RdaCommonStandardService.data_management_plan_permitted_params
        ).to_h
      end

      def check_agent
        expecting = "#{current_client[:name]} (#{current_client[:uid]})"
        request.headers.fetch('HTTP_USER_AGENT', nil).downcase == expecting.downcase
      end

      # Retrieve the specified DMP from the database and return a 404 if its either
      # not found or not owned by a client/application
      def load_dmp
        @doi = Identifier.where(value: params[:id], identifiable_type: 'DataManagementPlan').first
        @dmp = DataManagementPlan.where(id: @doi.identifiable_id).first if @doi.present?

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
