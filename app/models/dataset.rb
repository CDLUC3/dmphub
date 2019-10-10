# frozen_string_literal: true

# A dataset
class Dataset < ApplicationRecord
  include Identifiable

  enum dataset_type: %i[dataset software]

  # Associations
  belongs_to :data_management_plan, optional: true
  has_many :dataset_keywords, dependent: :destroy
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
      dataset = initialize_from_json(provenance: provenance, json: json, dmp: data_management_plan)

      dataset.description = json['description']
      dataset.dataset_type = json.fetch('type', 'dataset')
      dataset.publication_date = json['issued']
      dataset.language = json.fetch('language', 'en')
      dataset.personal_data = ConversionService.yes_no_unknown_to_boolean(json['personal_data'])
      dataset.sensitive_data = ConversionService.yes_no_unknown_to_boolean(json['sensitive_data'])
      dataset.data_quality_assurance = json['data_quality_assurance']
      dataset.preservation_statement = json['preservation_statement']

      identifiers_from_json(provenance: provenance, json: json, dataset: dataset)
      metadata_from_json(provenance: provenance, json: json, dataset: dataset)
      statements_from_json(provenance: provenance, json: json, dataset: dataset)
      technical_resources_from_json(provenance: provenance, json: json, dataset: dataset)
      keywords_from_json(json: json, dataset: dataset)
      distributions_from_json(provenance: provenance, json: json, dataset: dataset)

      dataset
    end

    private

    def initialize_from_json(provenance:, json:, dmp: nil)
      dataset = find_by_identifiers(provenance: provenance, json_array: json['dataset_ids'])
      unless dataset.present?
        dataset = find_or_initialize_by(
          title: json['title'],
          dataset_type: json.fetch('type', 'dataset'),
          data_management_plan: dmp
        )
      end
      dataset
    end

    def identifiers_from_json(provenance:, json:, dataset:)
      json.fetch('dataset_ids', []).each do |identifier|
        next unless identifier['value'].present?

        ident = {
          'provenance': provenance.to_s,
          'category': identifier.fetch('category', 'url'),
          'value': identifier['value'],
          'descriptor': 'is_metadata_for'
        }
        id = Identifier.from_json(json: ident, provenance: provenance)
        dataset.identifiers << id unless dataset.identifiers.include?(id)
      end
    end

    def statements_from_json(provenance:, json:, dataset:)
      json.fetch('security_and_privacy_statements', []).each do |sps|
        dataset.security_privacy_statements << SecurityPrivacyStatement.from_json(
          json: sps, provenance: provenance, dataset: dataset
        )
      end
    end

    def technical_resources_from_json(provenance:, json:, dataset:)
      json.fetch('technical_resources', []).each do |tr|
        dataset.technical_resources << TechnicalResource.from_json(json: tr,
                                                                   provenance: provenance, dataset: dataset)
      end
    end

    def metadata_from_json(provenance:, json:, dataset:)
      json.fetch('metadata', []).each do |metadatum|
        dataset.metadata << Metadatum.from_json(json: metadatum,
                                                provenance: provenance, dataset: dataset)
      end
    end

    def keywords_from_json(json:, dataset:)
      json.fetch('keywords', []).each do |keyword|
        next if keyword.blank?

        key = Keyword.find_or_initialize_by(value: keyword)
        dataset.dataset_keywords << DatasetKeyword.new(keyword: key)
      end
    end

    def distributions_from_json(provenance:, json:, dataset:)
      json.fetch('distributions', []).each do |distribution|
        dataset.distributions << Distribution.from_json(json: distribution, provenance: provenance,
                                                        dataset: dataset)
      end
    end
  end
end
