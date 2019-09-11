# frozen_string_literal: true

class CreateMetadata < ActiveRecord::Migration[6.0]
  def change
    create_table :metadata do |t|
      t.references  :dataset, index: true
      t.string      :language, null: false
      t.longtext    :description
      t.timestamps
    end
  end
end
