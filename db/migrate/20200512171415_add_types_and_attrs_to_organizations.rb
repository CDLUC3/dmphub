class AddTypesAndAttrsToOrganizations < ActiveRecord::Migration[6.0]
  def change
    add_column :organizations, :attrs, :json, null: false
    add_column :organizations, :types, :text
  end
end
