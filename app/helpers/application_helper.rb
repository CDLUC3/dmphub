# frozen_string_literal: true

# Generic helper
module ApplicationHelper

  def safe_date(date)
    return 'Unknown' unless date.is_a?(Time)
    date.strftime('%b. %d, %Y')
  end

  def orcid_link(id)
    return 'Unknown' unless id.present?
    link_to "https://orcid.org/#{id}", "https://orcid.org/#{id}"
  end

  def ror_link(id)
    return 'Unknown' unless id.present?
    link_to "https://ror.org/#{id}", "https://ror.org/#{id}"
  end

end
