# frozen_string_literal: true

json.ignore_nil!

# rubocop:disable Metrics/BlockLength
json.data do
  json.type 'dois'

  json.attributes do
    json.prefix prefix
    json.schemaVersion 'http://datacite.org/schema/kernel-4'

    json.types do
      json.ris 'DATA'
      json.bibtex 'misc'
      json.citeproc 'text'
      json.schemaOrg 'Text'
      json.resourceTypeGeneral 'Text'
    end

    creator = data_management_plan.person_data_management_plans.select { |per| per.role == 'primary_contact' }.first&.person
    if creator.present?
      json.creators do
        json.array! [creator] do |person|
          json.name person.name
          json.nameType 'Personal'

          if person.organizations.any?
            json.affiliation do
              json.array! person.organizations do |organization|
                json.name organization.name

                # Getting:
                #    {"status":"422","title":"found unpermitted parameters: :nameIdentifier, :nameIdentifierScheme"}
                # ror = organization.rors.first
                # if ror.present?
                #  json.schemeUri 'https://ror.org'
                #  json.nameIdentifier ror.value
                #  json.nameIdentifierScheme 'ROR'
                # end
              end
            end
          end

          orcid = person.orcids.first
          if orcid.present?
            json.nameIdentifiers do
              json.array! [orcid] do |ident|
                json.schemeUri 'https://orcid.org'
                json.nameIdentifier "https://orcid.org/#{ident.value}"
                json.nameIdentifierScheme 'ORCID'
              end
            end
          end
        end
      end
    end

    contributors = data_management_plan.person_data_management_plans.reject { |per| per.role == 'primary_contact' }
    if contributors.any?
      json.contributors contributors do |contributor|
        next unless contributor.person.present?

        person = contributor.person
        json.name person.name
        json.nameType 'Personal'
        json.contributorType contributor.role.humanize

        if person.organizations.any?
          json.affiliation do
            json.array! person.organizations do |organization|
              json.name organization.name

              # Getting:
              #    {"status":"422","title":"found unpermitted parameters: :nameIdentifier, :nameIdentifierScheme"}
              # ror = organization.rors.first
              # if ror.present?
              #  json.schemeUri 'https://ror.org'
              #  json.nameIdentifier ror.value
              #  json.nameIdentifierScheme 'ROR'
              # end
            end
          end
        end

        orcid = person.orcids.first
        if orcid.present?
          json.nameIdentifiers do
            json.array! [orcid] do |ident|
              # json.schemeUri 'https://orcid.org'
              json.nameIdentifier "https://orcid.org/#{ident.value}"
              json.nameIdentifierScheme 'ORCID'
            end
          end
        end
      end
    end

    json.titles do
      json.array! [data_management_plan.title] do |title|
        json.title title
      end
    end
    json.publisher provenance
    json.publicationYear Time.now.year

    json.dates [
      { type: 'Created', date: data_management_plan.created_at.to_s },
      { type: 'Updated', date: data_management_plan.updated_at.to_s }
    ] do |hash|
      json.date hash[:date]
      json.dateType hash[:type]
    end

    json.identifiers [data_management_plan.dois.first] do |doi|
      json.identifier "https://doi.org/#{doi}"
      json.identifierType 'DOI'
    end

    if data_management_plan.description.present?
      json.descriptions [data_management_plan.description] do |description|
        json.lang 'eng'
        json.description description
      end
    end

    # Getting:
    #    {"status":"422","title":"found unpermitted parameters: :nameIdentifier, :nameIdentifierScheme"}
    # if data_management_plan.projects.any?
    #  json.fundingReferences do
    #    project = data_management_plan.projects.first
    #    json.array! project.awards do |award|
    #      json.funderIdentifier award.funder_uri
    #      json.funderIdentifierType 'Crossref Funder ID'
    #      json.schemeUri 'https://www.crossref.org/services/funder-registry/'
    #    end
    #  end
    # end
  end
end
# rubocop:enable Metrics/BlockLength
