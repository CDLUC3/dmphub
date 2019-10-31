# frozen_string_literal: true

# Generic helper
module ApplicationHelper
  def safe_date(date:)
    return 'Unknown' unless date.is_a?(Time)

    date.strftime('%b. %d, %Y')
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
    return link_to(identifier.value, identifier.value) if identifier.value.start_with?('http')

    case identifier.category
    when 'doi'
      link_to "https://doi.org/#{identifier.value}", "https://dx.doi.org/#{identifier.value}"
    when 'orcid'
      link_to "https://orcid.org/#{identifier.value}",
              "https://orcid.org/#{identifier.value}",
              class: 'c-orcid'
    when 'ror'
      link_to "https://ror.org/#{identifier.value}", "https://ror.org/#{identifier.value}"
    else
      "#{identifier.category}:#{identifier.value}"
    end
  end

  def humanize_underscored(name:)
    return nil unless name.present?

    name.to_s.split('_').map(&:capitalize).join(' ')
  end

  def landing_page_path_with_doi(dmp:)
    return root_path unless dmp.id.present? && dmp.dois.first.present?

    id_to_doi(dmp: dmp, value: landing_page_path(dmp))
  end

  def landing_page_url_with_doi(dmp:)
    return root_url unless dmp.id.present? && dmp.dois.first.present?

    id_to_doi(dmp: dmp, value: landing_page_url(dmp))
  end

  def id_to_doi(dmp:, value:)
    value.gsub(dmp.id.to_s, dmp.dois.first)
  end

end
