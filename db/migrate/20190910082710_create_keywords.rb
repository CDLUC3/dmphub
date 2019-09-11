# frozen_string_literal: true

class CreateKeywords < ActiveRecord::Migration[6.0]
  def change
    create_table :keywords do |t|
      t.string      :value, null: false
      t.timestamps
    end

    create_table :datasets_keywords do |t|
      t.references :dataset, index: true
      t.references :keyword, index: true
      t.timestamps
    end
  end
end
