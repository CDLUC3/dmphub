class CreateDataManagementPlans < ActiveRecord::Migration[6.0]
  def change
    create_table :data_management_plans do |t|
      t.string      :title, null: false
      t.string      :language, null: false
      t.integer     :ethical_issues, default: 0
      t.timestamps
    end
  end
end
