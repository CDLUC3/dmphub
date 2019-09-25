class RemoveRoleIdFromUsers < ActiveRecord::Migration[6.0]
  def change
    remove_column :users, :role_id
  end
end
