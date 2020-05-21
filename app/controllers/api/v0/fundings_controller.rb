# frozen_string_literal: true

module Api
  module V0
    # Controller providing DMP functionality
    class FundingsController < BaseApiController
      protect_from_forgery with: :null_session, only: [:create]

      before_action :authorize_funding_assertions
      before_action :authorized_for_funding

      # GET /awards
      def index
        # funding_id = current_client[:profile].authorized_entities(entity_clazz: Funding)
        join_hash = {
          project: {
            data_management_plans: {
              contributors_data_management_plans: {
                contributor: { contributors_affiliations: :affiliation }
              }
            }
          }
        }
        @status = :ok
        @awards = paginate_response(results: Funding.joins(join_hash).includes(join_hash))
      end

      # PUT /awards/:id
      # rubocop:disable Metrics/AbcSize
      # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
      def update
        # Expecting the following format:
        # {
        #   "dmp": {
        #     "dmp_id": {
        #       'type': 'doi',
        #       'identifier': '10.234/erfere.234d'
        #     },
        #     "contributor": [{
        #       "name": 'Jane Doe',
        #       "mbox": 'jane.doe@example.org',
        #       "roles": 'https://credit.org/roles/program_officer',
        #       "affiliation": {
        #         "name": 'National Science Foundation (NSF)'
        #       },
        #     }],
        #     "project": {
        #       "start_on": '2020-05-15 10:34:21 UCT',
        #       "end_on": '2022-05-15 10:34:21 UCT',
        #       "funding": [{
        #         "name": "Example Funder",
        #         "funder_id": {
        #           'typer':'ROR',
        #           'identifier': 'http://ror.org/45y4545'
        #         },
        #         "grant_id": {
        #           'type': 'url',
        #           'identifier': 'http://awards.example.org/1234'
        #         }
        #         "funding_status": "granted"
        #       }]
        #     }
        #   }
        # }
        @funding = Funding.where(id: params[:id]).first
        if @funding.present? && funding_params.fetch('dmp_id', {}).any? &&
           funding_params['dmp_id']['identifier'].present? &&
           funding_params.fetch('project', {})['funding'].present?

          dmp = DataManagementPlan.find_by_doi(funding_params['dmp_Id']['identifier']).first
          if @funding.project.data_management_plans.first.id == dmp.id
            prepare_project_for_update(params: funding_params['project'])
            prepare_funding_for_update(params: funding_params['project']['funding'].first)

            if funding_params.fetch('contributor', []).any? && authorize_person_assertions
              DataManagementPlan.contributors_from_json(
                provenance: current_client[:name],
                dmp: dmp,
                json: funding_params
              )
            end

            if dmp.save && @funding.project.save && @funding.save
              head :no_content, location: landing_page_url(id: dmp.dois.first&.value)

            else
              project_errs = @funding.project.errors.collect { |e, m| { "#{e}": m } } || []
              funding_errs = @funding.errors.collect { |e, m| { "#{e}": m } } || []
              errs = (project_errs + funding_errs).join(', ')
              Rails.logger.warn "Error saving Project + Funding during api/v0/fundings#update: #{errs}"
              render_error errors: "Unable to assert your Funding: #{errs}", status: :unprocessable_entity
            end
          else
            render_error errors: 'Unauthorized', status: :unauthorized
          end
        else
          render_error errors: 'Unauthorized', status: :unauthorized
        end
      end
      # rubocop:enable Metrics/AbcSize
      # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

      private

      def funding_params
        params.require(:dmp).permit(data_management_plan_permitted_params).to_h
      end

      def authorize_funding_assertions
        current_client[:profile].funding_assertion?
      end

      def authorize_contributor_assertions
        current_client[:profile].contributor_assertion?
      end

      def authorized_for_funding
        current_client[:profile].authorized?(entity_clazz: Funding, id: params[:id])
      end

      def prepare_project_for_update(params:)
        project = @funding.project
        project.start_on = params['startOn'] unless project.start_on > Time.new(params['start'])
        project.end_on = params['endOn'] unless project.end_on > Time.new(params['end'])
      end

      def prepare_funding_for_update(params:)
        @funding.status = Funding.statuses[params['funding_status']] if params['funding_status'].present?

        grant_id = Identifier.from_json(provenance: current_client[:name], json: {
                                          category: 'url',
                                          value: params.fetch('grant_id', {})['identifier']
                                        })

        @funding.identifiers << grant_id if grant_id.present?
      end
    end
  end
end
