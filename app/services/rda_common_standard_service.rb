# frozen_string_literal: true

class RdaCommonStandardService

  class << self

    def award_permitted_params
      base_permitted_params + %i[funder_id funding_status grant_id]
    end

    def base_permitted_params
      %i[created modified links]
    end

    def cost_permitted_params
      base_permitted_params + %i[title description value currency_code]
    end

    def data_management_plan_permitted_params
      base_permitted_params +
      %i[title description language ethical_issues_exist
         ethical_issues_description ethical_issues_report] +
      [dm_staff: person_permitted_params, contact: person_permitted_params,
       datasets: dataset_permitted_params, costs: cost_permitted_params,
       project: project_permitted_params]
    end

    def dataset_permitted_params
      base_permitted_params +
      %i[title description type issued language personal_data sensitive_data
         keywords data_quality_assurance preservation_statement] +
      [dataset_ids: identifier_permitted_params,
       security_and_privacy_statements: security_and_privacy_statement_permitted_params,
       technical_resources: technical_resource_permitted_params,
       metadata: metadatum_permitted_params]
    end

    def distribution_permitted_params
      base_permitted_params +
      %i[title description format byte_size access_url download_url data_access
         available_until] +
      [licenses: license_permitted_params, host: host_permitted_params]
    end

    def host_permitted_params
      base_permitted_params +
      %i[title description supports_versioning backup_type backup_frequency
         storage_type availability geo_location] +
      [host_ids: identifier_permitted_params]
    end

    def identifier_permitted_params
      base_permitted_params + %i[provenance category value]
    end

    def license_permitted_params
      base_permitted_params + %i[license_ref start_date]
    end

    def metadatum_permitted_params
      base_permitted_params + %i[description language] +
      [identifier: identifier_permitted_params]
    end

    def person_permitted_params
      base_permitted_params + %i[name mbox contributor_type] +
      [contact_ids: identifier_permitted_params,
       user_ids: identifier_permitted_params]
    end

    def project_permitted_params
      base_permitted_params + %i[title description start_on end_on] +
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
