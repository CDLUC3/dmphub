class CreateProjects < ActiveRecord::Migration[6.0]
  def change
    create_table :projects do |t|
      t.string      :title, null: false
      t.timestamps
    end

    add_reference :data_management_plans, :project, index: true
  end
end
