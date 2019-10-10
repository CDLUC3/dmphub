class AddFunderNameToAwards < ActiveRecord::Migration[6.0]
  def change
    add_column :awards, :funder_name, :string, index: true
  end
end
