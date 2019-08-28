class CreateDatasets < ActiveRecord::Migration[6.0]
  def change
    create_table :datasets do |t|
      t.references  :data_management_plan, index: true
      t.string      :title, null: false
      t.integer     :dataset_type, null: false, default: 0, index: true
      t.boolean     :personal_data
      t.boolean     :sensitive_data
      t.timestamps
    end
  end
end