# frozen_string_literal: true

class CreateProjects < ActiveRecord::Migration[6.0]
  def change
    create_table :projects do |t|
      t.string :title, null: false
      t.datetime :start_on, null: false
      t.datetime :end_on, null: false
      t.longtext :description
      t.timestamps
    end

    add_reference :data_management_plans, :project, index: true
    add_index :projects, [:id, :start_on, :end_on]
  end
end
