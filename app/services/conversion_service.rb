# frozen_string_literal: true

# Provides conversion methods for JSON <--> Model
class ConversionService
  class << self
    # Converts a boolean field to [yes, no, unknown]
    def boolean_to_yes_no_unknown(value)
      return 'yes' if value == true

      return 'no' if value == false

      'unknown'
    end

    # Converts a [yes, no, unknown] field to boolean (or nil)
    def yes_no_unknown_to_boolean(value)
      return true if value == 'yes'

      return nil if value.blank? || value == 'unknown'

      false
    end

    # Returns the name of this application
    def local_provenance
      return Rails.application.class.name.split('::').first.downcase
    end

    # Converts input form params to RDA Common Standard JSON
    def data_management_plan_form_params_to_rda(params:)
      {
        'title': params['title'],
        'description': params['description'],
        'language': params['language'],
        'ethical_issues_exist': params['ethical_issues'],
        'ethical_issues_report': params['ethical_issues_report'],
        'ethical_issues_description': params['ethical_issues_description'],
        'project': project_form_params_to_rda(
          params: params['projects_attributes'],
          dmp_title: params['title']
        ).first,
        'dm-staff': person_form_params_to_rda(
          params: params['person_data_management_plans_attributes']
        )
      }
    end

    # Converts input form params to RDA Common Standard JSON
    def contact_form_params_to_rda(params:)
      {
        'name': params['name'],
        'mbox': params['email'],
        'contact_ids': identifier_form_params_to_rda(
          params: { category: 'orcid', value: params['value'] }
        )
      }
    end

    # Converts input form params to RDA Common Standard JSON
    def person_form_params_to_rda(params:)
      params.to_h.map do |idx, hash|
        {
          'name': hash['person_attributes']['name'],
          'mbox': hash['person_attributes']['email'],
          'user_ids': identifier_form_params_to_rda(params: hash['identifiers_attributes']),
          'contributor_type': hash['role']
        }
      end
    end

    # Converts input form params to RDA Common Standard JSON
    def project_form_params_to_rda(params:, dmp_title:)
      params.to_h.map do |idx, hash|
        {
          'title': hash['title'] || dmp_title,
          'description': hash['description'],
          'start_on': hash['start_on'],
          'end_on': hash['end_on'],
          'funding': award_form_params_to_rda(params: hash['awards_attributes'])
        }
      end
    end

    # Converts input form params to RDA Common Standard JSON
    def award_form_params_to_rda(params:)
      params.to_h.map do |idx, hash|
        {
          'funder_id': hash['funder_uri'],
          'funding_status': hash['status'],
          'grant_id': hash['identifiers_attributes'].to_h.first[1]&.fetch('value', nil)
        }
      end
    end

    # Converts input form params to RDA Common Standard JSON
    def identifier_form_params_to_rda(params:)
      params.to_h.map do |idx, hash|
        {
          'provenance': hash['provenance'] || local_provenance,
          'category': hash['category'] || 'url',
          'value': hash['value']
        }
      end
    end
  end
end
