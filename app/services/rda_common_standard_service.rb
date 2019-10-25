# frozen_string_literal: true

# Chainable permitted params for the entire RDS Common Standard Model
class RdaCommonStandardService
  class << self
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
end
