# frozen_string_literal: true

# Hook to add provenance association to models
module Alterable
  extend ActiveSupport::Concern

  included do
    belongs_to :provenance

    has_many :alterations, as: :alterable, class_name: 'ProvenanceAlteration'

    accepts_nested_attributes_for :provenance, :alterations

    validates_associated :alterations

    validates :provenance, presence: true

    before_save :record_alterations, if: :changed?

    protected

    def record_alterations
      throw(:abort) unless provenance.present?

p provenance.inspect

      alterations << ProvenanceAlteration.new(change_log: changes.to_json, provenance: provenance)
    end
  end
end
