# frozen_string_literal: true

# Generic helper
module ApplicationHelper

  def safe_date(date)
    return 'Unknown' unless date.is_a?(Time)
    date.strftime('%b. %d, %Y')
  end

  def identifier_to_link(identifier)
    return 'Unknown' unless identifier.present?
    return link_to(identifier.value, identifier.value) if identifier.value.start_with?('http')

    case identifier.category
    when 'doi'
      link_to "https://dx.doi.org/#{identifier.value}", "https://dx.doi.org/#{identifier.value}"
    when 'orcid'
      link_to "https://orcid.org/#{identifier.value}", "https://orcid.org/#{identifier.value}"
    when 'ror'
      link_to "https://ror.org/#{identifier.value}", "https://ror.org/#{identifier.value}"
    else
      "#{identifier.category}:#{identifier.value}"
    end
  end

end
