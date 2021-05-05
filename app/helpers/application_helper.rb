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

  def identifier_to_link(identifier:, text: '', show_default: true)
    return show_default ? 'Unknown' : nil unless identifier.present? || text.present?
    return text unless identifier.present?

    url = identifier_to_url(identifier: identifier)
    return url unless url.start_with?('http')
    return link_to text.blank? ? url : text, url, class: 'c-orcid', target: '_blank' if identifier.category == 'orcid'

    link_to text.blank? ? url : text, url, target: '_blank'
  end

  def identifier_to_url(identifier:)
    return nil unless identifier.present?
    return identifier.value unless identifier.present? && !identifier.value.start_with?('http')

    case identifier.category
    when 'doi'
      "https://dx.doi.org/#{identifier.value}"
    when 'orcid'
      "https://orcid.org/#{identifier.value}"
    when 'ror'
      "https://ror.org/#{identifier.value}"
    else
      identifier.category == 'other' ? identifier.value : "#{identifier.category}:#{identifier.value}"
    end
  end

  def orcid_without_url(value:)
    value.gsub(%r{^https?://orcid.org/}, '')
  end

  def role_to_link(role:)
    return '' unless role.present?

    # Swap out primary_contact with a CASRAI role
    role = 'http://credit.niso.org/contributor-roles/data-curation' if role == 'primary_contact'

    text = humanize_underscored(name: role.gsub('http://credit.niso.org/contributor-roles/', ''))
    link_to text, role, target: '_blank'
  end

  def host_to_link(host:)
    return '' unless host.present?

    # Look for a non-re3data url first
    link = host.urls.reject { |url| url.value.include?('re3data.org/api') }.first
    link = host.urls.first unless link.present?

    return link_to(host.title, link.value, target: '_blank', title: host.description) if link.present?

    "<host title=\"#{host.description}\">#{host.title}</host>"
  end

  # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  def latest_license_link(dataset:)
    return 'unspecified' unless dataset.present? && dataset.distributions.any?

    licenses = dataset.distributions.map(&:licenses).flatten.compact.uniq
    latest = licenses.min { |a, b| b&.start_date <=> a&.start_date }

    if latest.present? && latest.license_ref.present?
      link_to latest.display_name, latest.license_ref.gsub('.json', ''), target: '_blank'
    else
      'unspecified'
    end
  end
  # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

  def humanize_underscored(name:)
    return nil unless name.present?

    name.to_s.split('_').map(&:capitalize).join(' ')
  end

  def landing_page_path_with_doi(dmp:)
    # Temporarily override the default root_path behavior to redirect users to the DMPTool
    # until we have decided what to do for the search/dashboard
    root_path = Rails.env.production? ? 'https://dmptool.org/' : (Rails.env.stage? ? 'https://dmptool-stg.cdlib.org/' : 'https://dmptool-stg.cdlib.org/')

    return root_path unless dmp.id.present? && dmp.doi.present?

    id_to_doi(dmp: dmp, value: landing_page_path(dmp))
  end

  def landing_page_url_with_doi(dmp:)
    return root_url unless dmp.id.present? && dmp.doi.present?

    id_to_doi(dmp: dmp, value: landing_page_url(dmp))
  end

  # Swaps out the internal :id for the :doi value (sans URL prefix)
  def id_to_doi(dmp:, value:)
    return value unless dmp.doi.present?

    value.gsub(dmp.id.to_s, dmp.doi_without_prefix)
  end

  def citation(dmp:)
    # Author name. (yyy, mm, dd). Title of DMP (Version XX). DMPHub. DOI
    return '' unless dmp.present? && dmp.primary_contact.present? && dmp.dois.any?

    author = dmp.primary_contact.name
    pub_year = dmp.created_at.strftime('%Y')
    doi = identifier_to_link(identifier: dmp.dois.last)
    "#{author}. (#{pub_year}). \"#{dmp.title}\" [Data Management Plan]. DMPHub. #{doi}"
  end
end
