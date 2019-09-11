# frozen_string_literal: true

class CreateCosts < ActiveRecord::Migration[6.0]
  def change
    create_table :costs do |t|
      t.references  :data_management_plan, index: true
      t.string      :title, null: false
      t.longtext    :description
      t.float       :value
      t.string      :currency_code
      t.timestamps
    end
  end
end
