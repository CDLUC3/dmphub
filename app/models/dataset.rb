# frozen_string_literal: true

# A dataset
class Dataset < ApplicationRecord
  include Authorizable
  include Identifiable

  enum dataset_type: %i[dataset software http://purl.org/coar/resource_type/c_ddb1]

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

  def errors
    identifiers.each { |identifier| super.copy!(identifier.errors) }
    security_privacy_statements.each { |statement| super.copy!(statement.errors) }
    technical_resources.each { |resource| super.copy!(resource.errors) }
    metadata.each { |metadatum| super.copy!(metadatum.errors) }
    distributions.each { |distribution| super.copy!(distribution.errors) }
    super
  end

  # Scopes
  class << self
    # Common Standard JSON to an instance of this object
    def from_json!(provenance:, json:, data_management_plan:)
      return nil unless json.present? && provenance.present? && data_management_plan.present?

      json = json.with_indifferent_access
      return nil unless json['title'].present? || data_management_plan.title.present?

      dataset = find_by_identifiers(
        provenance: provenance,
        json_array: json['datasetIds']
      )

      dataset = Dataset.find_or_initialize_by(data_management_plan: data_management_plan, title: json.fetch('title', data_management_plan.title)) unless dataset.present?

      Dataset.transaction do
        dataset.description = json['description'] if json['description'].present?
        dataset.dataset_type = json.fetch('type', 'dataset')
        dataset.publication_date = json['issued'] if json['issued'].present?
        dataset.language = json.fetch('language', 'en')
        dataset.personal_data = ConversionService.yes_no_unknown_to_boolean(json['personalData'])
        dataset.sensitive_data = ConversionService.yes_no_unknown_to_boolean(json['sensitiveData'])
        dataset.data_quality_assurance = json['dataQualityAssurance'] if json['dataQualityAssurance'].present?
        dataset.preservation_statement = json['preservationStatement'] if json['preservationStatement'].present?

        json.fetch('securityAndPrivacyStatements', []).each do |sps|
          stmt = SecurityPrivacyStatement.from_json!(
            json: sps, provenance: provenance, dataset: dataset
          )
          dataset.security_privacy_statements << stmt unless dataset.security_privacy_statements.include?(stmt)
        end

        json.fetch('technicalResources', []).each do |tr|
          resource = TechnicalResource.from_json!(
            json: tr, provenance: provenance, dataset: dataset
          )
          dataset.technical_resources << resource unless dataset.technical_resources.include?(resource)
        end

        json.fetch('metadata', []).each do |metadatum|
          datum = Metadatum.from_json!(
            json: metadatum, provenance: provenance, dataset: dataset
          )
          dataset.metadata << datum unless dataset.metadata.include?(datum)
        end

        json.fetch('keywords', []).each do |keyword|
          next if keyword.blank?

          dk = DatasetKeyword.new(keyword: Keyword.find_or_initialize_by(value: keyword))
          dataset.dataset_keywords << dk unless dataset.dataset_keywords.include?(dk)
        end

        json.fetch('distributions', []).each do |distribution|
          distro = Distribution.from_json!(
            json: distribution, provenance: provenance, dataset: dataset
          )
          dataset.distributions << distro unless dataset.distributions.include?(distro)
        end

        json.fetch('datasetIds', []).each do |id|
          identifier = Identifier.from_json(provenance: provenance, json: id)
          dataset.identifiers << identifier unless dataset.identifiers.include?(identifier)
        end

        dataset.save
        dataset
      end
    end

  end
end
