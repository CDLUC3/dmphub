# frozen_string_literal: true

class CreateDatasets < ActiveRecord::Migration[6.0]
  def change
    create_table :datasets do |t|
      t.references  :data_management_plan, index: true
      t.string      :title, null: false
      t.integer     :dataset_type, null: false, default: 0, index: true
      t.boolean     :personal_data
      t.boolean     :sensitive_data
      t.longtext    :description
      t.datetime    :publication_date
      t.string      :language
      t.longtext    :data_quality_assurance
      t.longtext    :preservation_statement
      t.timestamps
    end
  end
end
