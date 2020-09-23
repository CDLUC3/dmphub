# frozen_string_literal: true

# Helpers for the DMP langing pages
module LandingHelper
  def role_to_link(role:)
    return '' unless role.present? && role != 'primary_contact'

    text = humanize_underscored(name: role.gsub('https://dictionary.casrai.org/Contributor_Roles/', ''))
    link_to text, role, target: '_blank'
  end
end
