# frozen_string_literal: true

module Api
  module V0
    # Base API Controller
    class BaseApiController < ApplicationController
      respond_to :json

      before_action :check_agent
      before_action :doorkeeper_authorize!, except: %i[heartbeat]
      before_action :has_doorkeeper_application_profile, except: %i[heartbeat]
      before_action :parse_request, except: %i[me heartbeat]
      before_action :pagination_params, only: %i[index]

      def me
        render json: current_client.to_json
      end

      def heartbeat
        render json: {
          application: Rails.application.class.name.split('::').first,
          status: 'ok'
        }
      end

      private

      def has_doorkeeper_application_profile
        @profile = OauthApplicationProfile.where(oauth_application_id: doorkeeper_token.application.id).first
        render_error errors: 'Unauthorized', status: :unauthorized and return unless @profile.present?
      end

      # Find the user that owns the access token
      def current_client
        {
          id: doorkeeper_token.application.id,
          uid: doorkeeper_token.application.uid,
          name: doorkeeper_token.application.name,
          redirect_uri: doorkeeper_token.application.redirect_uri,
          created_at: doorkeeper_token.application.created_at.to_s,
          profile: @profile
        }
      end

      def render_error(errors:, status:)
        @status = status.to_s.humanize
        @payload = {
            total_items: 0,
            items: [],
            errors: [errors]
          }
        render '/api/v0/data_management_plans/error', status: status
      end

      def base_response_content
        @application = Rails.application.class.name.split('::').first
        @caller = doorkeeper_token.application.name
      end

      # Make sure that the user agent matches the caller application/client
      def check_agent
        expecting = "#{current_client[:name]} (#{current_client[:uid]})"
        request.headers.fetch('HTTP_USER_AGENT', nil).downcase == expecting.downcase
      end

      # Parse the body of the incoming request
      def parse_request
        return false unless @request.present? && @request.body.present?

        begin
          @json = JSON.parse(@request.body.read)

        rescue JSON::ParserError => pe
          Rails.logger.error "JSON Parse error on #{@request.path} -> #{pe.message}"
          Rails.logger.error @request.headers
          Rails.logger.error @request.body
          return false
        end
      end

      def pagination_params
        @page = params.fetch('page', 1).to_i
        @per_page = params.fetch('per_page', 25).to_i
      end

      def paginate_response(results:)
        results.page(@page).per(@per_page)
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
           project: project_permitted_params, dmpIds: identifier_permitted_params]
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
  end
end
