# frozen_string_literal: true

class CreatePersonsDataManagementPlans < ActiveRecord::Migration[6.0]
  def change
    create_table :persons_data_management_plans do |t|
      t.references  :person, index: true
      t.references  :data_management_plan, index: true
      t.integer     :role
      t.timestamps
    end
  end
end
