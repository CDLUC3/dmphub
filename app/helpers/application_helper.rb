# frozen_string_literal: true

# Generic helper
module ApplicationHelper
  def safe_date(date:)
    return 'Unknown' unless date.is_a?(Time)

    date.strftime('%B %d, %Y')
  end

  def safe_language(language:)
    case language
    when 'fr'
      'French'
    when 'de'
      'German'
    when 'es'
      'Spanish'
    else
      'English'
    end
  end

  def identifier_to_link(identifier:)
    return 'Unknown' unless identifier.present?

    case identifier.category
    when 'orcid'
      link_to identifier_to_url(identifier: identifier), identifier_to_url(identifier: identifier),
              class: 'c-orcid', target: '_blank'
    else
      link_to identifier_to_url(identifier: identifier), identifier_to_url(identifier: identifier),
              target: '_blank'
    end
  end

  def identifier_to_url(identifier:)
    return nil unless identifier.present?
    return identifier.value unless identifier.present? && !identifier.value.start_with?('http')

    url = case identifier.category
          when 'doi'
            "https://dx.doi.org/#{identifier.value}"
          when 'orcid'
            "https://orcid.org/#{identifier.value}"
          when 'ror'
            "https://ror.org/#{identifier.value}"
          else
            "#{identifier.category}:#{identifier.value}"
          end

    url.start_with?('http') ? link_to((text || url), url, target: '_blank') : url
  end

  def orcid_without_url(value:)
    value.gsub(%r{^https?://orcid.org/}, '')
  end

  def role_to_link(role:)
    return '' unless role.present?

    # Swap out primary_contact with a CASRAI role
    role = 'https://dictionary.casrai.org/Contributor_Roles/Data_curation' if role == 'primary_contact'

    text = humanize_underscored(name: role.gsub('https://dictionary.casrai.org/Contributor_Roles/', ''))
    link_to text, role, target: '_blank'
  end

  def humanize_underscored(name:)
    return nil unless name.present?

    name.to_s.split('_').map(&:capitalize).join(' ')
  end

  def landing_page_path_with_doi(dmp:)
    return root_path unless dmp.id.present? && dmp.doi.present?

    id_to_doi(dmp: dmp, value: landing_page_path(dmp))
  end

  def landing_page_url_with_doi(dmp:)
    return root_url unless dmp.id.present? && dmp.doi.present?

    id_to_doi(dmp: dmp, value: landing_page_url(dmp))
  end

  def id_to_doi(dmp:, value:)
    doi = dmp.doi&.value
    return value unless doi.present?

    prefix = Rails.configuration.x.ezid[:doi_prefix]
    value.gsub(dmp.id.to_s, doi.gsub(prefix, 'doi:'))
  end

  def citation(dmp:)
    # Author name. (yyy, mm, dd). Title of DMP (Version XX). DMPHub. DOI
    return '' unless dmp.present? && dmp.primary_contact.present? && dmp.dois.any?

    "#{dmp.primary_contact.name}. (#{dmp.created_at.strftime('%y, %m, %d')}). \"#{dmp.title}\". DMPHub. #{identifier_to_link(identifier: dmp.dois.last)}"
  end
end
