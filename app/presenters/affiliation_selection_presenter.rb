# frozen_string_literal: true

# Helper methods for views that have the Affiliation selector
class AffiliationSelectionPresenter
  attr_accessor :suggestions

  def initialize(affiliations:, selection:)
    @crosswalk = []

    affiliations = [selection] if !affiliations.present? || affiliations.empty?

    @crosswalk = affiliations.map do |affiliation|
      next if affiliation.nil?

      AffiliationSelection::AffiliationToHashService.to_hash(affiliation: affiliation)
    end
  end

  # Return the Affiliation name unless this is the default is_other Affiliation
  attr_reader :name

  def crosswalk
    @crosswalk.to_json
  end

  def select_list
    @crosswalk.map { |rec| rec[:name] }.to_json
  end

  def crosswalk_entry_from_affiliation_id(value:)
    return {}.to_json unless value.present? && value.to_s =~ /[0-9]+/

    entry = @crosswalk.select { |item| item[:id].to_s == value.to_s }.first
    entry.present? ? entry.to_json : {}.to_json
  end
end
