# frozen_string_literal: true

# A dataset
class Dataset < ApplicationRecord

  include Identifiable

  enum dataset_type: %i[dataset software]

  # Associations
  belongs_to :data_management_plan, optional: true
  has_many :dataset_keywords
  has_many :keywords, through: :dataset_keywords
  has_many :security_privacy_statements, dependent: :destroy
  has_many :technical_resources, dependent: :destroy
  has_many :metadata, dependent: :destroy
  has_many :distributions, dependent: :destroy

  # Validations
  validates :title, :dataset_type, presence: true

  # Scopes
  class << self

    # Common Standard JSON to an instance of this object
    def from_json(json:, provenance:)
      return nil unless json.present? && provenance.present? && json['title'].present?

      json = json.with_indifferent_access
      dataset = new(
        title: json['title'],
        description: json['description'],
        dataset_type: json.fetch('type', 'dataset'),
        publication_date: json['issued'],
        language: json['language'],
        personal_data: ConversionService.yes_no_unknown_to_boolean(json['personal_data']),
        sensitive_data: ConversionService.yes_no_unknown_to_boolean(json['sensitive_data']),
        data_quality_assurance: json['data_quality_assurance'],
        preservation_statement: json['preservation_statement']
      )

      json.fetch('security_and_privacy_statements', []).each do |sps|
        dataset.security_privacy_statements << SecurityPrivacyStatement.from_json(json: sps, provenance: provenance)
      end
      json.fetch('technical_resources', []).each do |tr|
        dataset.technical_resources << TechnicalResource.from_json(json: tr, provenance: provenance)
      end
      json.fetch('metadata', []).each do |metadatum|
        dataset.metadata << Metadatum.from_json(json: metadatum, provenance: provenance)
      end

      json.fetch('identifiers', []).each do |identifier|
        next unless identifier['value'].present?

        # Convert the grant_id into an identifier record
        ident = {
          'provenance': provenance.to_s,
          'category': identifier.fetch('category', 'url'),
          'value': identifier['value']
        }
        dataset.identifiers << Identifier.from_json(json: ident, provenance: provenance)
      end

      json.fetch('keywords', []).each do |keyword|
        next if keyword.blank?
        dataset.keywords << Keyword.new(value: keyword)
      end
      json.fetch('distributions', []).each do |distribution|
        dataset.distributions << Distribution.from_json(json: distribution, provenance: provenance)
      end
      dataset
    end

  end
end
