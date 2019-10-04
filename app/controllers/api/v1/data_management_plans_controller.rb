# frozen_string_literal: true

# See below for an example of the JSON output

module Api
  module V1
    # Controller providing DMP functionality
    # rubocop:disable Metrics/ClassLength
    class DataManagementPlansController < BaseApiController
      protect_from_forgery with: :null_session, only: [:create]

      before_action :load_dmp, except: %i[index create]
      before_action :check_agent

      PARTIAL = 'api/v1/rd_common_standard/data_management_plans_show.json.jbuilder'

      # GET /data_management_plans
      def index
        # TODO: We need a better way to distinguish between client types and who can see what
        unless current_client[:name] === 'national_science_foundation'
          dmps = DataManagementPlan.by_client(client_id: current_client[:id]).order(updated_at: :desc)

        else
          query = <<-SQL
            SELECT dmp.id, dmp.title, dmp.created_at, dmp.updated_at,
                   (SELECT i.value FROM identifiers i
                    WHERE i.identifiable_id = dmp.id
                    AND i.identifiable_type = 'DataManagementPlan'
                    AND i.category = 1),
                   (SELECT GROUP_CONCAT(DISTINCT p.email ORDER BY p.email SEPARATOR ', ')
                    FROM persons_data_management_plans pdmp
                      INNER JOIN persons p ON pdmp.person_id = p.id
                    WHERE pdmp.data_management_plan_id = dmp.id
                    AND pdmp.role = 'primary_contact'),
                   (SELECT GROUP_CONCAT(
                      DISTINCT
                      CONCAT(p.name, CONCAT('|', o.name))
                      ORDER BY p.name SEPARATOR ', ')
                    FROM persons_data_management_plans pdmp
                      INNER JOIN persons p ON pdmp.person_id = p.id
                      LEFT OUTER JOIN persons_organizations po ON po.person_id = p.id
                      LEFT OUTER JOIN organizations o ON po.organization_id = o.id
                    WHERE pdmp.data_management_plan_id = dmp.id)
            FROM data_management_plans dmp
              INNER JOIN projects proj ON dmp.id = proj.data_management_plan_id
              INNER JOIN awards a ON proj.id = a.project_id
            WHERE a.funder_uri = 'https://dx.doi.org/10.13039/100000001'
              AND (LENGTH(dmp.title) - LENGTH(REPLACE(dmp.title, ' ', '')) + 1) > 5
            LIMIT 250
          SQL

          results = ActiveRecord::Base.connection.execute(query)

          # TODO: Need to think security through!
          #       Just giving NSF Awards API authorization on the DMP by default
          #       Might make sense to do it when we first receive the DMP if it
          #       is funded by NSF?
          #results.each do |result|
          #  OauthAuthorization.find_or_create_by(
          #    oauth_application: doorkeeper_token.application,
          #    data_management_plan_id: result[0]
          #  )
          #end

          dmps = results.collect do |result|
            OpenStruct.new({
              title: result[1],
              created_at: result[2],
              updated_at: result[3],
              doi: result[4],
              primary_contact: result[5],
              authors: result[6]
            })
          end
        end

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
      # rubocop:disable Metrics/AbcSize
      # rubocop:disable Metrics/MethodLength
      def create
        @dmp = DataManagementPlan.from_json(json: dmp_params, provenance: current_client[:name])
        if @dmp.present? && @dmp.new_record? && @dmp.save
          # Mint the DOI if we did not recieve a DOI in the input
          @dmp.mint_doi(provenance: current_client[:name])
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
          if @dmp.errors.any?
            errs = { 'errors': (@dmp.errors.collect { |e, m| { "#{e}": m } } || []) }
            errs[:errors] << { dmp: 'already exists' } unless @dmp.new_record?
            render_error errors: errs[:errors]
          else
            render_show dmp: @dmp, status: 201
          end
        end
      rescue ActionController::ParameterMissing
        render_error errors: [{ dmp: 'invalid json format' }]
      end
      # rubocop:enable Metrics/AbcSize
      # rubocop:enable Metrics/MethodLength
      # rubocop:enable Metrics/CyclomaticComplexity
      # rubocop:enable Metrics/PerceivedComplexity

      # PUT /data_management_plans/:id
      def update
        if @dmp.present?
          if dmp_params['dm_staff'].present? && dmp_params['dm_staff'].any?
            dmp_params['dm_staff'].each do |person|

p person.inspect

              per = Person.from_json(json: person, provenance: current_client[:name])

p per.inspect

              pdmp = PersonDataManagementPlan.new(
                person: per, role: person.fetch('contributor_type', 'author')
              )
              existing = @dmp.person_data_management_plans.collect { |r| r.person }
              @dmp.person_data_management_plans << pdmp unless existing.include?(per)
            end
          end

          award = Award.from_json(json: dmp_params['project']['funding'].first,
            provenance: current_client[:name], project: @dmp.projects.first)
          award.save unless award.new_record?
          @dmp.projects.first.awards << award if award.new_record?

          @dmp.save

          render_show dmp: @dmp, status: 200
        else
          render_error errors: [{ dmp: 'not found' }]
        end
      end

      # DELETE /data_management_plans/:id
      def delete; end

      private

      def render_show(dmp:, status:)
        render 'show', locals: {
          data_management_plan: dmp,
          caller: current_client[:name],
          source: "POST #{api_v1_data_management_plans_url}"
        }, status: status
      end

      def render_error(errors:)
        p errors.inspect

        render 'error', locals: {
          caller: current_client[:name],
          source: "POST #{api_v1_data_management_plans_url}",
          errors: errors
        }, status: :bad_request
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
    # rubocop:enable Metrics/ClassLength
  end
end
