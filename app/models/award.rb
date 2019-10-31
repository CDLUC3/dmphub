# frozen_string_literal: true

# A data management plan
class Award < ApplicationRecord
  include Identifiable

  enum status: %i[planned applied granted rejected]

  # Associations
  belongs_to :project, optional: true
  belongs_to :organization

  accepts_nested_attributes_for :identifiers, :organization

  def funded?
    granted? && urls.any?
  end

  def errors
    identifiers.each { |identifier| super.copy!(identifier.errors) }
    super.copy!(organization.errors) if organization.present?
    super
  end

  class << self
    # Common Standard JSON to an instance of this object
    def from_json!(provenance:, json:, project:)
      return nil unless json.present? && provenance.present? && project.present?

      json = json.with_indifferent_access
      return nil unless json['funderId'].present?

      Award.transaction do
        # find or create the Award URL
        award_url = Identifier.from_json(provenance: provenance, json: {
          'category': 'url', 'value': json['grantId']
        })
        # Find or create the Funder Organization
        funder = Organization.from_json!(provenance: provenance, json: {
          'name': json['funderName'],
          'identifiers': [{ 'category': 'doi', 'value': json['funderId'] }]
        })

        existing_award = locate_existing_award(project: project, funder: funder)

        award = initialize_award(project: project, funder: funder, json: json,
          award_url: award_url, existing_award: existing_award)

        award.status = json['fundingStatus']

        # Process any other identifiers
        json.fetch('awardIds', []).each do |id|
          identifier = Identifier.from_json(provenance: provenance, json: id)
          award.identifiers << identifier unless award.identifiers.include?(identifier)
        end
        award.save
        award
      end
    end

    private

    # Determine which award to use
    def initialize_award(project:, funder:, award_url:, json:, existing_award:)
      # If the Award URL is not present or its a new one
      if !award_url.present? || award_url.new_record?
        # If the Project has no awards for this Funder
        if !existing_award.present?
          # Create a new Award for the funder and attach the Award URL
          award = Award.new(project: project, organization: funder,
                            status: json.fetch('fundingStatus', 'planned'))
          award.identifiers << award_url if award_url.present?
        else
          # Update the award for the funder
          award = existing_award
          award.identifiers << award_url if award_url.present?
        end
      else
        # Update the Award associated with the Award URL
        award = Award.find_by(id: award_url.identifiable_id)
      end
      award
    end

    # Look for existing planned or applied awards for the Funder
    def locate_existing_award(project:, funder:)
      existing_awards = project.awards.select do |award|
        !%w[rejected granted].include?(award.status) && award.organization == funder
      end
      return nil if existing_awards.empty?

      existing_award = existing_awards.sort { |a, b| b.updated_at<=>a.updated_at }.first
    end

  end
end
