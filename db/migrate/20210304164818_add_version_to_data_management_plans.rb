class AddVersionToDataManagementPlans < ActiveRecord::Migration[6.0]
  def change
    add_column :data_management_plans, :version, :datetime
  end
end
