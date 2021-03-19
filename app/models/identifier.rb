# frozen_string_literal: true

# == Schema Information
#
# Table name: identifiers
#
#  id                :bigint           not null, primary key
#  value             :string(255)      not null
#  category          :integer          default("ark"), not null
#  identifiable_id   :bigint
#  identifiable_type :string(255)
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  descriptor        :integer          default("is_funded_by")
#  provenance_id     :bigint
#
class Identifier < ApplicationRecord
  include Alterable

  # Based on the DataCite 4.3 schema relatedIdentifierType
  enum category: %i[ark arxiv bibcode credit doi duns ean13 eissn fundref handle
                    igsn isbn isni issn istc lissn lsid openid orcid pmid program
                    purl ror sub_program url urn w3id other]

  # Based on the DataCite 4.3 schema relationType plus the following for internal use:
  #   is_identified_by   ->  links a model to its external identifier (e.g. ROR, ORCID, etc.)
  #   is_funded_by       ->  The grant associated with a funding
  #
  # Note that the 'references' value is changed to 'does_reference' in this list
  # because 'references' conflicts with an ActiveRecord method
  enum descriptor: %i[is_funded_by is_identified_by
                      cites is_cited_by
                      compiles is_compiled_by
                      continues is_continued_by
                      describes is_described_by
                      documents is_documented_by
                      has_metadata is_metadata_for
                      has_version is_version_of is_new_version_of is_previous_version_of
                      has_part is_part_of
                      is_derived_from is_identical_to is_original_form_of
                      is_source_of is_supplemented_by is_supplement_to
                      is_variant_form_of
                      obsoletes is_obsoleted_by
                      does_reference is_referenced_by
                      requires is_required_by
                      reviews is_reviewed_by]

  # Associations
  belongs_to :identifiable, polymorphic: true
  has_one :citation, required: false, dependent: :destroy

  # Validations
  validates :category, :value, :provenance, presence: true

  # Categories that need to be universally unique (e.g. DOI, URL or ORCID)
  # Should be unique for the :category
  validates :value, uniqueness: { scope: %i[category], case_sensitive: false },
                    if: proc { |id| requires_universal_uniqueness.include?(id.category) }
  # Other categories (e.g. PROGRAM) should be unique per provenance + identifiable
  validates :value, uniqueness: { scope: %i[category provenance_id identifiable_id],
                                  case_sensitive: false },
                    unless: proc { |id| requires_universal_uniqueness.include?(id.category) }

  # Scopes
  scope :by_provenance_and_category_and_value, lambda { |provenance:, category:, value:|
    ret = where(category: category, value: value)
    ret = ret.where(provenance: provenance) unless requires_universal_uniqueness.include?(category.to_sym)
    ret
  }

  private

  def requires_universal_uniqueness
    ::Identifier.requires_universal_uniqueness
  end

  class << self
    # Categories that REQUIRE that the value is unique regardless of provenance
    # and Identifiable type
    def requires_universal_uniqueness
      %i[ark doi orcid ror fundref url credit]
    end
  end
end
