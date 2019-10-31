class AddAlternateNamesToOrganizations < ActiveRecord::Migration[6.0]
  def change
    add_column :organizations, :alternate_names, :text
  end
end
