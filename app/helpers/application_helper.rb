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

  def identifier_to_link(identifier:, text: '')
    return 'Unknown' unless identifier.present?

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
      "#{identifier.category}:#{identifier.value}"
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

  def latest_license_link(dataset:)
    return 'unspecified' unless dataset.present? && dataset.distributions.any?

    licenses = dataset.distributions.map { |distro| distro.licenses  }.flatten.compact.uniq
    latest = licenses.sort { |a, b| b&.start_date <=> a&.start_date }.first
    return link_to latest.license_ref if latest.present? && latest.license_ref.present?

    'unspecified'
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

    ark_prefix = Rails.configuration.x.ezid[:ark_prefix]
    doi_prefix = Rails.configuration.x.ezid[:doi_prefix]
    ret = value.gsub(dmp.id.to_s, doi.gsub(doi_prefix, 'doi:')) if doi_prefix.present? && doi.include?(doi_prefix)
    ret = value.gsub(dmp.id.to_s, doi.gsub(ark_prefix, 'ark:')) if ark_prefix.present? && doi.include?(ark_prefix)

    ret || doi
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
