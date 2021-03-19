class AddSourcePrivacyToDataManagementPlans < ActiveRecord::Migration[6.0]
  def change
    add_column :data_management_plans, :source_privacy, :integer, default: 0
  end
end
