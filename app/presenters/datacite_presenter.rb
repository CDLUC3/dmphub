# frozen_string_literal: true

# Presenter for DataCite XML
class DatacitePresenter
  attr_reader :creators, :contributors

  def initialize(dmp)
    @dmp = dmp
    @creators = find_creators
    @contributors = find_contributors
  end

  # Cleans out / escapes any characters that EZID's ANVL format does not like
  # see https://ezid.cdlib.org/doc/apidoc.html#request-response-bodies
  def scrub(text)
    return '' unless text.present?

    text.to_s.gsub(/[\r\n]/, ' ').gsub('%', '%25')
  end

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

  private

  def find_creators
    ret = [@dmp.primary_contact]
    @dmp.contributors_data_management_plans.each do |cdmp|
      ret << cdmp.contributor if cdmp.role == 'https://dictionary.casrai.org/Contributor_Roles/Writing_original_draft'
    end
    ret.flatten
  end

  def find_contributors
    exclusions = creators
    @dmp.contributors_data_management_plans.reject { |cdmp| exclusions.include?(cdmp.contributor) }
  end
end
