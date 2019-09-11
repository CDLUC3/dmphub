# frozen_string_literal: true

class CreateTechnicalResources < ActiveRecord::Migration[6.0]
  def change
    create_table :technical_resources do |t|
      t.references  :dataset, index: true
      t.longtext    :description
      t.timestamps
    end
  end
end
