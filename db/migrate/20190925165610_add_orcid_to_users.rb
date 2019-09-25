class AddOrcidToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :orcid, :string
  end
end
