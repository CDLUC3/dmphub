class AddDataManagementPlanToProjects < ActiveRecord::Migration[6.0]
  def change
    add_reference :projects, :data_management_plan, index: true
  end
end
