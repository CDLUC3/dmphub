class AddOrganizationToAwards < ActiveRecord::Migration[6.0]
  def change
    add_reference :awards, :organization, index: true
    remove_column :awards, :funder_uri
    remove_column :awards, :funder_name
  end
end
