# frozen_string_literal: true

# Presenter for DataCite XML
class DatacitePresenter
  attr_reader :creators, :contributors, :related_identifiers, :producers

  def initialize(dmp)
    @dmp = dmp
    @creators = find_creators
    @contributors = find_contributors
    @related_identifiers = find_related
    @producers = find_producers
  end

  # Cleans out / escapes any characters that EZID's ANVL format does not like
  # see https://ezid.cdlib.org/doc/apidoc.html#request-response-bodies
  def scrub(text)
    return '' unless text.present?

    text.to_s.gsub(/[\r\n]/, ' ').gsub('%', '%25')
  end

  # Convert the CASRAI roles to DataCite contributorType
  # rubocop:disable Metrics/CyclomaticComplexity
  def role_for(cdmp)
    case cdmp.role
    when 'https://dictionary.casrai.org/Contributor_Roles/Data_curation'
      'DataCurator'
    when 'https://dictionary.casrai.org/Contributor_Roles/Formal_analysis'
      'Researcher'
    when 'https://dictionary.casrai.org/Contributor_Roles/Investigation'
      'ProjectLeader'
    when 'https://dictionary.casrai.org/Contributor_Roles/Methodology'
      'DataManager'
    when 'https://dictionary.casrai.org/Contributor_Roles/Project_administration'
      'ProjectManager'
    when 'https://dictionary.casrai.org/Contributor_Roles/Software'
      'Producer'
    when 'https://dictionary.casrai.org/Contributor_Roles/Supervision'
      'Supervisor'
    when 'https://dictionary.casrai.org/Contributor_Roles/Validation'
      'Researcher'
    when 'https://dictionary.casrai.org/Contributor_Roles/Writing_review_Editing'
      'Editor'
    else
      'ProjectMember'
    end
  end
  # rubocop:enable Metrics/CyclomaticComplexity

  # Retrieve the award URI without the URL portion for DataCite's <AwardNumber>
  # rubocop:disable Metrics/CyclomaticComplexity
  def award_number(funding:)
    return '' unless funding.funded? && funding.affiliation&.fundrefs&.any?
    return '' unless funding.urls.last.present?

    mapping = Rails.configuration.x.funders[:award_urls]
    return funding.urls.last.value unless mapping.present?

    funding.urls.last.value&.gsub(mapping[:"#{funding.affiliation.fundrefs.last.value}"], '')
  end
  # rubocop:enable Metrics/CyclomaticComplexity

  # Retrieve the landing page URL for EZID's _target (where the DOI will resolve to)
  def landing_page
    url = Rails.application.routes.url_helpers.data_management_plan_url(@dmp)
    url.gsub('dmphub1', 'dmphub').gsub('dmphub2', 'dmphub')
  end

  # Used to set the DataCite HostingInstitution <contributor>
  def hosting_institution
    {
      name: Rails.configuration.x.ezid[:hosting_institution],
      scheme: Rails.configuration.x.ezid[:hosting_institution_scheme],
      identifier: Rails.configuration.x.ezid[:hosting_institution_identifier]
    }
  end

  # Converts the Identifier's category into a DataCite relatedIdentifierType
  def related_identifier_type(identifier:)
    case identifier.category
    when 'arxiv'
      'arXiv'
    when %w[bibcode w3id]
      identifier.category.to_s
    when %w[handle]
      identifier.category.to_s.capitalize
    when %w[doi ean13 eissn igsn isbn issn istc lissn lsid pmid purl upc url urn]
      identifier.category.to_s.upcase
    else
      identifier.value.to_s.start_with?('http') ? 'URL' : 'Handle'
    end
  end

  # Converts the Identifier's descriptor to a DataCite relationType
  def relation_type(identifier:)
    return 'isReferencedBy' unless identifier.present? && identifier.descriptor.present?
    # Due to a conflict between ActiveRecord's 'references' method we store that
    # descriptor as 'does_reference'
    return 'References' if identifier.descriptor == 'does_reference'

    identifier.descriptor.to_s.split('_').map(&:capitalize).join
  end

  # Strips out the URL portion of the DOI and replaces it with 'doi:'
  def url_to_doi(value:)
    return value unless value.present? && value.start_with?('http')

    value.gsub(%r{^https?://do[a-z].org/}, 'doi:').strip
  end

  def affiliation_name_without_contextual(name:)
    name.to_s.gsub(/\(.*\)\s?$/, '')
  end

  private

  # Retrieves all of the contributors who were authors of the DMP for DataCite's <creators>
  def find_creators
    ret = [@dmp.primary_contact]
    @dmp.contributors_data_management_plans.each do |cdmp|
      ret << cdmp.contributor if cdmp.role == 'https://dictionary.casrai.org/Contributor_Roles/Writing_original_draft'
    end
    ret.flatten
  end

  # Retrieves all of the contributors who are not authors of the DMP for DatCite's <contributors>
  def find_contributors
    exclusions = creators
    @dmp.contributors_data_management_plans.reject { |cdmp| exclusions.include?(cdmp.contributor) }
  end

  # Retrieves all of the funder_affiliations (or the creator's affiliation) for
  # DataCite's Producer <contributor>
  def find_producers
    defaults = creators.map(&:affiliation).compact
    return defaults unless @dmp.project.present? && @dmp.project.fundings.any?
    return defaults unless @dmp.project.fundings.map(&:funded_affiliations).flatten.uniq.any?

    @dmp.project.fundings.map(&:funded_affiliations).flatten.uniq
  end

  # Retrieves all of the identifiers for DataCite's <relatedIdentifiers>
  def find_related
    # Skip any descriptors that are used internally to relate an Identifier to its Identifiable
    @dmp.identifiers.reject { |id| %w[is_identified_by is_funded_by].include?(id.descriptor) }
  end
end
