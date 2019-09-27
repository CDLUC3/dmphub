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

p @dmp.inspect
p @dmp.person_data_management_plans.inspect

        if @dmp.present? && @dmp.new_record? && @dmp.save
          # Mint the DOI if we did not recieve a DOI in the input
          mint_doi!(dmp: @dmp)

p @errors.inspect

          if @errors.nil? && @dmp.save
            # Associate the DMP with the Client/Application who created it
            OauthAuthorization.find_or_create_by(
              oauth_application: doorkeeper_token.application,
              data_management_plan: @dmp
            )
            render_show dmp: @dmp
          else
            rollback(dmp: @dmp)
            errs = { 'errors': (@dmp.errors.collect { |e, m| { "#{e}": m } } || []) }
            render_error errors: (errs[:errors] << @errors)
          end
        else
          errs = { 'errors': (@dmp.errors.collect { |e, m| { "#{e}": m } } || []) }
          render_error errors: (errs[:errors] << { dmp: 'already exists' }) unless @dmp.new_record?
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
        @errors = { dmp: 'unable to register a DOI at this time' } unless doi.present?
        dmp.identifiers << Identifier.new(provenance: 'datacite', category: 'doi', value: doi) if doi.present?
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

      def rollback(dmp:)
        return false if dmp.new_record?

        # delete the entire DMP hierarchy since we could not mint the DOI
        dmp.projects.each do |project|
          rollback_project(project: project)
        end

        dmp.datasets.each do |dataset|
          rollback_dataset(dataset: dataset)
        end

        Identifier.where(identifiable_id: dmp.id, identifiable_type: 'DataManagementPlan').destroy_all
        OauthAuthorization.where(data_management_plan_id: dmp.id).destroy_all

        dmp.costs.destroy_all
        dmp.person_data_management_plans.destroy_all

        dmp.destroy
      end

      def rollback_project(project:)
        project.awards.each do |award|
          Identifier.where(identifiable_id: award.id, identifiable_type: 'Award').destroy_all
          award.destroy
        end
        project.destroy
      end

      def rollback_dataset(dataset:)
        dataset.distributions.each do |distribution|
          rollback_distribution(distribution: distribution)
        end

        dataset.metadata.each do |metadatum|
          Identifier.where(identifiable_id: metadatum.id, identifiable_type: 'Metadatum').destroy_all
          metadatum.destroy
        end
        dataset.technical_resources.each do |tech|
          Identifier.where(identifiable_id: tech.id, identifiable_type: 'TechnicalResource').destroy_all
          tech.destroy
        end
        dataset.security_privacy_statements.destroy_all
        dataset.dataset_keywords.destroy_all

        dataset.destroy
      end

      def rollback_distribution(distribution:)
        if distribution.host.present?
          Identifier.where(identifiable_id: distribution.host.id, identifiable_type: 'Host').destroy_all
          distribution.host.destroy
        end
        distribution.licenses.destroy_all
      end
    end
  end
end
