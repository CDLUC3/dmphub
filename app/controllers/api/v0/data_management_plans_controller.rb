# frozen_string_literal: true

module Api
  module V0
    # Controller providing DMP functionality
    # rubocop:disable Metrics/ClassLength
    class DataManagementPlansController < BaseApiController
      protect_from_forgery with: :null_session, only: [:create]

      before_action :base_response_content

      def index
        dmp_ids = ApiClientAuthorization.by_api_client_and_type(
          api_client_id: client[:id],
          authorizable_type: 'DataManagementPlan'
        ).pluck(:authorizable_id)

        @payload = { items: DataManagementPlan.where(id: dmp_ids) }
      end

      # GET /data_management_plans/:id
      def show
        @dmp = DataManagementPlan.find_by_doi(params[:id]).first
        @dmp = DataManagementPlan.where(id: params[:id]).first unless @dmp.present?

        if authorized?
          id = @dmp.dois.any? ? @dmp.dois.last : @dmp.id
          @source = "GET #{api_v0_data_management_plan_url(id)}"
        else
          render_error(errors: [], status: :not_found)
        end
      end

      # POST /data_management_plans
      # rubocop:disable Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity
      def create
        # Only proceed if the Application has permission
        if permitted?
          @dmp = Api::V0::Deserialization::DataManagementPlan.deserialize(
            provenance: provenance, json: dmp_params.to_h.with_indifferent_access
          )

          if @dmp.present?
            if @dmp.new_record?
              # rubocop:disable Metrics/BlockNesting
              render_error errors: ["Invalid JSON format - #{@dmp.errors}"], status: :bad_request unless @dmp.valid?
              # rubocop:enable Metrics/BlockNesting

              process_dmp
            else
              doi = @dmp.dois.last || @dmp.urls.last
              msg = 'DMP already exists try sending an update to the attached :dmp_id instead'
              render_error errors: [msg], status: :method_not_allowed, items: [doi]
            end
          elsif provenance.present?
            msg = 'You must include at least a :title, :contact (with :mbox) and :dmp_id (with :identifier)'
            render_error errors: ["Invalid JSON format - #{msg}"], status: :bad_request
          else
            msg = 'The :dmp must include a :title, { dmp_id: :identifier } and { contact: :mbox }'
            render_error errors: ["Invalid JSON format - #{msg}"], status: :bad_request
          end
        else
          render_error errors: 'Unauthorized', status: :unauthorized
        end
      rescue ActionController::ParameterMissing => e
        render_error errors: "Invalid json format (#{e.message})", status: :bad_request
      end
      # rubocop:enable Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity

      private

      def dmp_params
        params.require(:dmp).permit(plan_permitted_params)
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
        return false unless client.present? && client.permissions.any?

        client.permissions.where(permission: 'data_management_plan_creation').any?
      end

      def authorized?
        @dmp.present? && client.present? && @dmp.authorized?(api_client: client)
      end

      # Determine what to render
      def process_dmp
        action = @dmp.new_record? ? 'add' : 'edit'
        @dmp = safe_save
        render_error errors: @dmp.errors.full_messages, status: :bad_request unless @dmp.valid?

        @dmp.mint_doi(provenance: provenance) unless @dmp.dois.any?

        ApiClientAuthorization.create(authorizable: @dmp, api_client: client)
        ApiClientHistory.create(api_client: client, data_management_plan: @dmp, change_type: action,
                                description: "#{request.method} #{request.url}")
        @dmp = @dmp.reload

        render 'show', status: :created unless @dmp.dois.empty? && @dmp.arks.empty?

        render_error errors: 'Unable to acquire a DOI at this time. Please try your request later.',
                     status: 500
      end

      # prevent scenarios where we have two contributors with the same affiliation
      # from trying to create the record twice
      def safe_save
        @dmp.project = safe_save_project(project: @dmp.project)
        safe = []
        @dmp.contributors_data_management_plans.each do |cdmp|
          safe << safe_save_contributor(cdmp: cdmp)
        end
        @dmp.contributors_data_management_plans = safe.compact.uniq
        @dmp
      end

      def safe_save_identifier(identifier:)
        return nil unless identifier.present?
        return identifier.save if identifier.valid?

        Identifier.where(category: identifier.category, value: identifier.value,
                         identifiable: identifier.identifiable)
      end

      def safe_save_project(project:)
        return nil unless project.present?

        project.fundings.each do |f|
          f.affiliation = safe_save_affiliation(affiliation: f.affiliation)
        end
        project.save
        project
      end

      def safe_save_affiliation(affiliation:)
        return nil unless affiliation.present?

        affil = Affiliation.find_or_create_by(name: affiliation.name)
        if affil.new_record?
          affil.update(saveable_attributes(attrs: affiliation.attributes))
          affiliation.identifiers.each do |id|
            id.identifiable = affil.reload
            safe_save_identifier(identifier: id)
          end
        end
        affil
      end

      def safe_save_contributor(cdmp:)
        return nil unless cdmp.present? && cdmp.contributor.present?

        contrib = cdmp.contributor
        contrib.affiliation = safe_save_affiliation(affiliation: contrib.affiliation)
        cdmp.contributor = Contributor.find_or_create_by(email: contrib.email)

        if cdmp.contributor.new_record?
          cdmp.contributor.update(saveable_attributes(attrs: contrib.attributes))
          contrib.identifiers.each do |id|
            id.identifiable = cdmp.contributor.reload
            safe_save_identifier(identifier: id)
          end
          cdmp.save
        end

        cdmp
      end

      def saveable_attributes(attrs:)
        %w[id created_at updated_at].each { |key| attrs.delete(key) }
        attrs
      end
    end
    # rubocop:enable Metrics/ClassLength
  end
end
