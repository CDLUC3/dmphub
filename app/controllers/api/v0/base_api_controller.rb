# frozen_string_literal: true

module Api
  module V0
    # Base API Controller
    # rubocop:disable Metrics/ClassLength
    class BaseApiController < ApplicationController
      # Skipping the standard Rails authenticity tokens passed in UI
      skip_before_action :verify_authenticity_token

      respond_to :json

      # Verify the JWT
      before_action :authorize_request, except: %i[heartbeat]

      # Prep default instance variables for views
      before_action :set_default_response_format
      before_action :base_response_content
      before_action :pagination_params, except: %i[heartbeat]

      # Parse the incoming JSON
      before_action :parse_request, only: %i[create update]

      attr_reader :client, :provenance

      def heartbeat
        render 'api/v0/heartbeat', status: :ok
      end

      protected

      def render_error(errors:, status:, items: [])
        @payload = { errors: errors, items: items }
        render '/api/v0/error', status: status
      end

      private

      attr_accessor :json

      # ==========================
      # CALLBACKS
      # ==========================
      def authorize_request
        auth_svc = Api::V0::Auth::Jwt::AuthorizationService.new(
          headers: request.headers
        )
        @client = auth_svc.call
        @provenance = Provenance.by_api_client(api_client: client).first if @client.present?
        log_access if @client.present?
        return true if @client.present? && check_agent

        render_error(errors: auth_svc.errors, status: :unauthorized)
      end

      # Make sure that the user agent matches the caller application/client
      def check_agent
        expecting = "#{client.name.gsub(/\s/, '')}(#{client.client_id})".downcase
        received = request.headers.fetch('HTTP_SERVER_AGENT', request.headers.fetch('HTTP_USER_AGENT', ''))
        received.downcase.gsub(/\s/, '') == expecting
      end

      # Force all responses to be in JSON format
      def set_default_response_format
        request.format = :json
      end

      # Set the generic application and caller variables used in all responses
      def base_response_content
        @application = ApplicationService.application_name
        @caller = caller_name
      end

      # Retrieve the requested pagination params or use defaults
      # only allow 100 per page as the max
      def pagination_params
        @page = params.fetch('page', 1).to_i
        @per_page = params.fetch('per_page', 20).to_i
        @per_page = 100 if @per_page > 100
      end

      # Parse the body of the incoming request
      def parse_request
        return false unless request.present? && request.body.present?

        begin
          body = request.body.read
          @json = JSON.parse(body).with_indifferent_access
        rescue JSON::ParserError => e
          Rails.logger.error "JSON Parser: #{e.message}"
          Rails.logger.error request.body
          render_error(errors: 'Invalid JSON format', status: :bad_request)
          false
        end
      end

      # ==========================

      def log_error(error:)
        Rails.logger.error "Incoming params: #{params.inspect}"
        # Rails.logger.error "Incoming headers: #{request.headers.inspect}"
        Rails.logger.error error.message
        Rails.logger.error error.backtrace[0..5]
      end

      def log_access
        obj = client
        return false unless obj.present?

        obj.update(last_access: Time.now) if obj.is_a?(ApiClient)
        true
      end

      # Returns either the User name or the ApiClient name
      def caller_name
        obj = client
        return request.remote_ip unless obj.present?

        obj.name
      end

      # Applies pagination to specified ActiveRecord Resultset
      def paginate_response(results:)
        results = results.page(@page).per(@per_page)
        @total_items = results.total_count
        results
      end

      # =========================
      # PERMIITTED PARAMS HEPERS
      # =========================
      def plan_permitted_params
        %i[created modified title description language ethical_issues_exist
           ethical_issues_description ethical_issues_report] +
          [dmp_id: identifier_permitted_params,
           contact: contributor_permitted_params,
           contributor: contributor_permitted_params,
           cost: cost_permitted_params,
           project: project_permitted_params,
           dataset: dataset_permitted_params,
           dmproadmap_template: %i[id title],
           dmproadmap_latest_version: %i[uri],
           dmphub_related_identifiers: %i[relation_type identifier],
           extensions: %i[uri name]]
      end

      def identifier_permitted_params
        %i[type identifier]
      end

      def contributor_permitted_params
        %i[name mbox] +
          [role: [],
           affiliation: affiliation_permitted_params,
           contributor_id: identifier_permitted_params,
           contact_id: identifier_permitted_params]
      end

      def affiliation_permitted_params
        %i[name abbreviation] +
          [affiliation_id: identifier_permitted_params]
      end

      def cost_permitted_params
        %i[title description value currency_code]
      end

      def project_permitted_params
        %i[title description start end] +
          [funding: funding_permitted_params]
      end

      def funding_permitted_params
        %i[name funding_status] +
          [funder_id: identifier_permitted_params,
           grant_id: identifier_permitted_params,
           dmproadmap_funding_opportunity_id: identifier_permitted_params,
           dmproadmap_funded_affiliations: [affiliation_permitted_params]]
      end

      def dataset_permitted_params
        %i[title description type issued language personal_data sensitive_data
           keywords data_quality_assurance preservation_statement] +
          [dataset_id: identifier_permitted_params,
           metadata: metadatum_permitted_params,
           security_and_privacy: security_and_privacy_statement_permitted_params,
           technical_resource: technical_resource_permitted_params,
           distribution: distribution_permitted_params]
      end

      def metadatum_permitted_params
        %i[description language] + [metadata_standard_id: identifier_permitted_params]
      end

      def security_and_privacy_statement_permitted_params
        [:title, description: []]
      end

      def technical_resource_permitted_params
        %i[title description]
      end

      def distribution_permitted_params
        %i[title description format byte_size access_url download_url
           data_access available_until] +
          [license: license_permitted_params, host: host_permitted_params]
      end

      def license_permitted_params
        %i[license_ref start_date]
      end

      def host_permitted_params
        %i[title description supports_versioning backup_type backup_frequency
           storage_type availability geo_location certified_with pid_system url] +
          [dmproadmap_host_id: identifier_permitted_params]
      end

      def related_identifier_params
        %i[datacite_relation_type datacite_related_identifier_type value]
      end
    end
    # rubocop:enable Metrics/ClassLength
  end
end
