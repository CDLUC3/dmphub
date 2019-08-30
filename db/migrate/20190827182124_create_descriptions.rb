# frozen_string_literal: true

class CreateDescriptions < ActiveRecord::Migration[6.0]
  def change
    create_table :descriptions do |t|
      t.text        :value, null: false
      t.integer     :category, null: false, index: true, default: 0
      t.bigint      :describable_id
      t.string      :describable_type
      t.timestamps
    end
  end
end
