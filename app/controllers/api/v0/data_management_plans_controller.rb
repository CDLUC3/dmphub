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
        @source = "POST #{api_v0_data_management_plans_url}"
        @dmp = DataManagementPlan.from_json(json: dmp_params, provenance: current_client[:name])
        render_error errors: 'Invalid json format', status: :bad_request unless @dmp.present?

        if @dmp.project.save
          # Mint the DOI if we did not recieve a DOI in the input
          @dmp.mint_doi(provenance: current_client[:name]) if @dmp.present? && @dmp.new_record?

          if @dmp.save
            setup_authorizations(dmp: @dmp)
            @status = 'created'
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

      rescue ActionController::ParameterMissing => pm
        render_error errors: "Invalid json format (#{pm.message})", status: :bad_request
      end

      private

      def dmp_params
        params.require(:dmp).permit(data_management_plan_permitted_params).to_h
      end

      def render_error(errors:, status:)
        @status = status.to_s.humanize
        @payload = {
            total_items: 0,
            items: [],
            errors: [errors]
          }
        render 'error', status: status
      end

      def setup_authorizations(dmp:)
        return nil unless dmp.present? && dmp.is_a?(DataManagementPlan)

        # Associate the DMP with the Client/Application who created it
        AuthorizationService.authorize!(dmp: dmp, entity: doorkeeper_token.application)

        # If funding was defined then authorize the funder application/client to
        # make award level assertions on the DMP
        #dmp.projects.awards.each do |award|
        #  identifier = award.organization.identifiers.select { |i| i.category == 'doi' }.first
        #  if identifier.present?
        #    entity = OauthApplication.where()
        #  end
        #end
      end

      def retrieveDataManagementPlan(downloadUrl:)
        # TODO: if a downloadURL was provided, retrieve the file and then
        #       send it to the repository service for preservation
      end

      def award_permitted_params
        base_permitted_params +
          %i[funderId funderName fundingStatus grantId] +
          [award_ids: identifier_permitted_params]
      end

      def base_permitted_params
        %i[created modified links]
      end

      def cost_permitted_params
        base_permitted_params + %i[title description value currencyCode]
      end

      def data_management_plan_permitted_params
        base_permitted_params +
          %i[title description language ethicalIssuesExist
             ethicalIssuesDescription ethicalIssuesReport downloadURL] +
          [dmStaff: person_permitted_params, contact: person_permitted_params,
           datasets: dataset_permitted_params, costs: cost_permitted_params,
           project: project_permitted_params, dmp_ids: identifier_permitted_params]
      end

      def dataset_permitted_params
        base_permitted_params +
          %i[title description type issued language personalData sensitiveData keywords
             dataQualityAssurance preservationStatement] +
          [datasetIds: identifier_permitted_params,
           securityAndPrivacyStatements: security_and_privacy_statement_permitted_params,
           technicalResources: technical_resource_permitted_params,
           metadata: metadatum_permitted_params,
           distributions: distribution_permitted_params]
      end

      def distribution_permitted_params
        base_permitted_params +
          %i[title description format byteSize accessUrl downloadUrl dataAccess
             availableUntil] +
          [licenses: license_permitted_params, host: host_permitted_params]
      end

      def host_permitted_params
        base_permitted_params +
          %i[title description supportsVersioning backupType backupFrequency
             storageType availability geoLocation certifiedWith pidSystem] +
          [hostIds: identifier_permitted_params]
      end

      def identifier_permitted_params
        base_permitted_params + %i[provenance category value]
      end

      def keyword_permitted_params
        base_permitted_params + %i[value]
      end

      def license_permitted_params
        base_permitted_params + %i[licenseRef startDate]
      end

      def metadatum_permitted_params
        base_permitted_params + %i[description language] +
          [identifier: identifier_permitted_params]
      end

      def organization_permitted_params
        base_permitted_params + %i[name] + [identifiers: identifier_permitted_params]
      end

      def person_permitted_params
        base_permitted_params + %i[name mbox contributorType] +
          [contactIds: identifier_permitted_params,
           staffIds: identifier_permitted_params,
           organizations: organization_permitted_params]
      end

      def project_permitted_params
        base_permitted_params + %i[title description startOn endOn] +
          [funding: award_permitted_params]
      end

      def security_and_privacy_statement_permitted_params
        base_permitted_params + %i[title description]
      end

      def technical_resource_permitted_params
        base_permitted_params + %i[description] +
          [identifier: identifier_permitted_params]
      end
    end
    # rubocop:enable Metrics/ClassLength
  end
end
