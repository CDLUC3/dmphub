class SwapProjectDataManagementPlansRelationship < ActiveRecord::Migration[6.0]
  def change
    remove_reference :projects, :data_management_plan
  end
end
