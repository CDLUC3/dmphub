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
    def from_json(json:, provenance:, data_management_plan: nil)
      return nil unless json.present? && provenance.present? && json['title'].present?

      json = json.with_indifferent_access
      dataset = find_by_identifiers(
        provenance: provenance,
        json_array: json['dataset_ids']
      )
      dataset = find_or_initialize_by(
        title: json['title'],
        dataset_type: json.fetch('type', 'dataset'),
        data_management_plan: data_management_plan
      ) unless dataset.present?

      dataset.description = json['description']
      dataset.dataset_type = json.fetch('type', 'dataset')
      dataset.publication_date = json['issued']
      dataset.language = json.fetch('language', 'en')
      dataset.personal_data = ConversionService.yes_no_unknown_to_boolean(json['personal_data'])
      dataset.sensitive_data = ConversionService.yes_no_unknown_to_boolean(json['sensitive_data'])
      dataset.data_quality_assurance = json['data_quality_assurance']
      dataset.preservation_statement = json['preservation_statement']

      json.fetch('security_and_privacy_statements', []).each do |sps|
        dataset.security_privacy_statements << SecurityPrivacyStatement.from_json(json: sps,
          provenance: provenance, dataset: dataset)
      end
      json.fetch('technical_resources', []).each do |tr|
        dataset.technical_resources << TechnicalResource.from_json(json: tr, provenance: provenance,
          dataset: dataset)
      end
      json.fetch('metadata', []).each do |metadatum|
        dataset.metadata << Metadatum.from_json(json: metadatum, provenance: provenance, dataset: dataset)
      end

      json.fetch('dataset_ids', []).each do |identifier|
        next unless identifier['value'].present?

        ident = {
          'provenance': provenance.to_s,
          'category': identifier.fetch('category', 'url'),
          'value': identifier['value']
        }
        id = Identifier.from_json(json: ident, provenance: provenance)
        dataset.identifiers << id unless dataset.identifiers.include?(id)
      end

      json.fetch('keywords', []).each do |keyword|
        next if keyword.blank?
        key = Keyword.find_or_initialize_by(value: keyword)
        dataset.dataset_keywords << DatasetKeyword.new(keyword: key)
      end

      json.fetch('distributions', []).each do |distribution|
        dataset.distributions << Distribution.from_json(json: distribution, provenance: provenance,
          dataset: dataset)
      end
      dataset
    end

  end
end
