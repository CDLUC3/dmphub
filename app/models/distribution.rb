# frozen_string_literal: true

# == Schema Information
#
# Table name: distributions
#
#  id              :bigint           not null, primary key
#  dataset_id      :bigint
#  title           :string(255)      not null
#  description     :text(4294967295)
#  format          :string(255)
#  byte_size       :float(24)
#  access_url      :string(255)
#  download_url    :string(255)
#  data_access     :integer
#  available_until :datetime
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  provenance_id   :bigint
#  host_id         :bigint
#
# A Dataset Distribution
class Distribution < ApplicationRecord
  include Alterable
  include Authorizable

  enum data_access: %i[open embargoed restricted closed]

  # Associations
  belongs_to :dataset, optional: true
  belongs_to :host, optional: true
  has_many :licenses, dependent: :destroy

  # Validations
  validates :title, presence: true
end
