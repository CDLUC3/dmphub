# frozen_string_literal: true

# == Schema Information
#
# Table name: alterations
#
#  id             :bigint           not null, primary key
#  alterable_id   :bigint           not null
#  alterable_type :string(255)      default(""), not null
#  change_log     :text(65535)      not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  provenance_id  :bigint           not null
#
# A change log
class Alteration < ApplicationRecord
  # Associations
  belongs_to :provenance

  belongs_to :alterable, polymorphic: true

  # validations
  validates :provenance, :alterable, :change_log, presence: true
end
