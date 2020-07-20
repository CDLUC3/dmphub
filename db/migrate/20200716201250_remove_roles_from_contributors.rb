class RemoveRolesFromContributors < ActiveRecord::Migration[6.0]
  def change
    remove_column :contributors, :roles
  end
end
