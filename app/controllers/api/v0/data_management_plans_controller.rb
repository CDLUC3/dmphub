# frozen_string_literal: true

module Api
  module V0
    # Controller providing DMP functionality
    # rubocop:disable Metrics/ClassLength
    class DataManagementPlansController < BaseApiController
      protect_from_forgery with: :null_session, only: [:create]

      before_action :base_response_content
      before_action :doi_param_to_dmp, only: %w[show update delete]

      def index
        dmp_ids = ApiClientAuthorization.by_api_client_and_type(
          api_client_id: client[:id],
          authorizable_type: 'DataManagementPlan'
        ).pluck(:authorizable_id)

        @payload = { items: DataManagementPlan.where(id: dmp_ids) }
      end

      # GET /data_management_plans/:id
      def show
        if authorized?
          @source = "GET #{api_v0_data_management_plan_url(id: params[:id])}"
        else
          render_error(errors: [], status: :not_found)
        end
      end

      # POST /data_management_plans
      # rubocop:disable Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity
      # rubocop:disable Metrics/MethodLength
      def create
        # Only proceed if the Application has permission
        if permitted?
          @dmp = Api::V0::Deserialization::DataManagementPlan.deserialize(
            provenance: provenance, json: dmp_params.to_h.with_indifferent_access
          )

          if @dmp.present?
            if @dmp.new_record?
              # rubocop:disable Metrics/BlockNesting
              if @dmp.valid?
                process_dmp

                if @dmp.dois.any? || @dmp.arks.any?
                  render 'show', status: :created
                else
                  render_error errors: ['Unable to acquire a DOI at this time. Please try your request later.'],
                               status: 500
                end
              else
                errs = model_errors(model: @dmp)
                errs += model_errors(model: @dmp.project)
                
p model_errors(model: @dmp)
                render_error errors: ["Invalid JSON format - #{errs}"], status: :bad_request
              end
              # rubocop:enable Metrics/BlockNesting
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
      rescue StandardError => e
        log_error(error: e)
        render_error errors: [e.message], status: :bad_request
      end
      # rubocop:enable Metrics/MethodLength
      # rubocop:enable Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity

      private

      def dmp_params
        params.require(:dmp).permit(plan_permitted_params)
      end

      # Convert the incoming DOI/ARK/URL into a DMP
      def doi_param_to_dmp
        case params[:id][0..3]
        when 'doi:'
          @dmp = Identifier.where('value LIKE ?', "%#{params[:id].gsub('doi:', '')}")
                           .where(category: 'doi', descriptor: 'is_identified_by')
                           .first&.identifiable
        when 'ark:'
          @dmp = Identifier.where('value LIKE ?', "%#{params[:id].gsub('ark:', '')}")
                           .where(category: 'ark', descriptor: 'is_identified_by')
                           .first&.identifiable
        when 'url:'
          # Allows for retrieving the record by the associated object's URL
          @dmp = Identifier.where('value LIKE ?', "%#{params[:id].gsub('url', '')}")
                           .where(category: 'url', descriptor: 'is_metadata_for')
                           .first&.identifiable
        end
        p @dmp.inspect
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

        ActiveRecord::Base.transaction do
          @dmp = safe_save
          @dmp = @dmp.reload
          raise StandardError, @dmp.errors.full_messages unless @dmp.valid?

          @dmp.mint_doi(provenance: provenance) unless @dmp.doi.present?

          ApiClientAuthorization.create(authorizable: @dmp, api_client: client)
          ApiClientHistory.create(api_client: client, data_management_plan: @dmp, change_type: action,
                                  description: "#{request.method} #{request.url}")
        end

        @dmp.reload
      end

      # prevent scenarios where we have two contributors with the same affiliation
      # from trying to create the record twice
      def safe_save
        @dmp.project = safe_save_project(project: @dmp.project)
        @dmp.contributors_data_management_plans = @dmp.contributors_data_management_plans.map do |cdmp|
          safe_save_contributor_data_management_plan(cdmp: cdmp)
        end
        @dmp.datasets = safe_save_datasets(datasets: @dmp.datasets)
        @dmp.save
        @dmp.reload
      end

      def safe_save_identifier(identifier:)
        return nil unless identifier.present?

        identifier.transaction do
          return identifier.save if identifier.valid?
        end

        Identifier.where(category: identifier.category, value: identifier.value,
                         identifiable: identifier.identifiable)
      end

      def safe_save_project(project:)
        return nil unless project.present?

        project.fundings.each do |f|
          f.affiliation = safe_save_affiliation(affiliation: f.affiliation)
        end

        project.transaction do
          project.save
        end

        project
      end

      def safe_save_datasets(datasets:)
        return [] unless datasets.any?

        datasets.map do |dataset|
          dataset.metadata = dataset.metadata.map do |metadatum|
            safe_save_metadatum(metadatum: metadatum)
          end
          dataset.distributions.each do |distribution|
            distribution.licenses = distribution.licenses.map do |license|
              safe_save_license(license: license)
            end
            distribution.host = safe_save_host(host: distribution.host)
          end
          dataset
        end
      end

      def safe_save_host(host:)
        return host unless host.present? && host.urls.any?

        Host.transaction do
          url = host.urls.first
          id = Identifier.find_or_initialize_by(value: url.value, category: url.category,
                                                descriptor: url.descriptor)
          return id.identifiable unless id.new_record?

          hst = Host.find_or_create_by(title: host.title)
          hst.update(saveable_attributes(attrs: host.attributes)) if hst.new_record?

          id.identifiable = hst
          id.save
          hst.reload
        end
      end

      def safe_save_license(license:)
        return license unless license.present? && license.license_ref.present?

        License.transaction do
          lcnse = license.find_or_create_by(license_ref: license.license_ref)
          lcnse.update(description: license.description) if lcnse.new_record?
          lcnse.reload
        end
      end

      def safe_save_metadatum(metadatum:)
        return metadatum unless metadatum.present? && metadatum.urls.any?

        Metadatum.transaction do
          url = metadatum.urls.first
          id = Identifier.find_or_initialize_by(value: url.value, category: url.category,
                                                descriptor: url.descriptor)
          return id.identifiable unless id.new_record?

          datum = Metadatum.find_or_create_by(description: metadatum.description,
                                              language: metadatum.language)
          id.identifiable = datum
          id.save
          datum.reload
        end
      end

      def safe_save_affiliation(affiliation:)
        return nil unless affiliation.present?

        Affiliation.transaction do
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
      end

      def safe_save_contributor_data_management_plan(cdmp:)
        return nil unless cdmp.present? && cdmp.contributor.present?

        cdmp.transaction do
          cdmp.contributor = safe_save_contributor(contributor: cdmp.contributor)
        end
        cdmp
      end

      def safe_save_contributor(contributor:)
        return nil unless contributor.present?

        Contributor.transaction do
          contributor.affiliation = safe_save_affiliation(affiliation: contributor.affiliation)

          contrib = Contributor.find_or_create_by(email: contributor.email) if contributor.email.present?
          contrib = Contributor.find_or_create_by(name: contributor.name) unless contributor.email.present?
          contrib.provenance = contributor.provenance

          if contrib.new_record?
            contrib.update(saveable_attributes(attrs: contributor.attributes))
            contributor.identifiers.each do |id|
              id.identifiable = contrib.reload
              safe_save_identifier(identifier: id)
            end
          end
          contrib.reload
        end
      end

      def saveable_attributes(attrs:)
        %w[id created_at updated_at].each { |key| attrs.delete(key) }
        attrs
      end
    end
    # rubocop:enable Metrics/ClassLength
  end
end
