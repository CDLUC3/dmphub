# frozen_string_literal: true

module Api
  module V0
    # Controller providing DMP functionality
    class AwardsController < BaseApiController
      protect_from_forgery with: :null_session, only: [:create]

      before_action :authorize_award_assertions
      before_action :authorized_for_award

      # GET /awards
      def index
        # award_ids = current_client[:profile].authorized_entities(entity_clazz: Award)
        join_hash = {
          project: {
            data_management_plans: {
              person_data_management_plans: {
                person: { person_organizations: :organization }
              }
            }
          }
        }
        @status = :ok
        @awards = paginate_response(results: Award.joins(join_hash).includes(join_hash))
      end

      # PUT /awards/:id
      # rubocop:disable Metrics/AbcSize
      # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
      def update
        # Expecting the following format:
        # {
        #   "dmp": {
        #     "dmpIds": [{
        #       'category': 'doi',
        #       'value': '10.234/erfere.234d'
        #     }],
        #     "dmStaff": [{
        #       "name": 'Jane Doe',
        #       "mbox": 'jane.doe@example.org',
        #       "contributorType": 'program_officer',
        #       "organizations": [{
        #         "name": 'National Science Foundation (NSF)'
        #       }],
        #     }],
        #     "project": {
        #       "startOn": award[:project_start],
        #       "endOn": award[:project_end],
        #       "funding": [{
        #         "funderId": 'http://dx.doi/path/to/funder',
        #         "grantId": 'http://awards.example.org/1234',
        #         "fundingStatus": "granted",
        #         "awardIds": [{
        #           'category': 'program',
        #           'value': 'Genomics'
        #         }]
        #       }]
        #     }
        #   }
        # }
        @award = Award.where(id: params[:id]).first
        if @award.present? && award_params.fetch('dmpIds', []).any? &&
           award_params['dmpIds'].first['value'].present? &&
           award_params.fetch('project', {})['funding'].present?

          dmp = DataManagementPlan.find_by_doi(award_params['dmpIds'].first['value']).first
          if @award.project.data_management_plans.first.id == dmp.id
            prepare_project_for_update(params: award_params['project'])
            prepare_award_for_update(params: award_params['project']['funding'].first)

            if award_params.fetch('dmStaff', []).any? && authorize_person_assertions
              DataManagementPlan.persons_from_json(
                provenance: current_client[:name],
                dmp: dmp,
                json: award_params
              )
            end

            if dmp.save && @award.project.save && @award.save
              head :no_content, location: landing_page_url(id: dmp.dois.first&.value)

            else
              project_errs = @award.project.errors.collect { |e, m| { "#{e}": m } } || []
              award_errs = @award.errors.collect { |e, m| { "#{e}": m } } || []
              errs = (project_errs + award_errs).join(', ')
              Rails.logger.warn "Error saving Project + Award during api/v0/awards#update: #{errs}"
              render_error errors: "Unable to assert your Award: #{errs}", status: :unprocessable_entity
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

      def award_params
        params.require(:dmp).permit(data_management_plan_permitted_params).to_h
      end

      def authorize_award_assertions
        current_client[:profile].award_assertion?
      end

      def authorize_person_assertions
        current_client[:profile].person_assertion?
      end

      def authorized_for_award
        current_client[:profile].authorized?(entity_clazz: Award, id: params[:id])
      end

      def prepare_project_for_update(params:)
        project = @award.project
        project.start_on = params['startOn'] unless project.start_on > Time.new(params['startOn'])
        project.end_on = params['endOn'] unless project.end_on > Time.new(params['endOn'])
      end

      def prepare_award_for_update(params:)
        @award.status = Award.statuses[params['fundingStatus']] if params['fundingStatus'].present?

        grant_id = Identifier.from_json(provenance: current_client[:name], json: {
                                          category: 'url',
                                          value: params['grantId']
                                        })

        p "GRANT ID: #{grant_id}"

        @award.identifiers << grant_id if grant_id.present?
        params.fetch('awardIds', []).each do |identifier|
          ident = Identifier.from_json(provenance: current_client[:name], json: identifier)

          p "IDENT: #{ident}"

          @award.identifiers << ident unless @award.identifiers.include?(ident)
        end
      end
    end
  end
end
