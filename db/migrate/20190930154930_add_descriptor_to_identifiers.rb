class AddDescriptorToIdentifiers < ActiveRecord::Migration[6.0]
  def change
    add_column :identifiers, :descriptor, :integer, default: 0
  end
end
