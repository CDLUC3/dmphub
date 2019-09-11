# frozen_string_literal: true

class CreateSecurityAndPrivacy < ActiveRecord::Migration[6.0]
  def change
    create_table :security_privacy_statements do |t|
      t.references  :dataset, index: true
      t.string      :title, null: false
      t.longtext    :description
      t.timestamps
    end
  end
end
