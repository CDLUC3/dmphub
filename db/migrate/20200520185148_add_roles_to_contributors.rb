class AddRolesToContributors < ActiveRecord::Migration[6.0]
  def change
    add_column :contributors, :roles, :text
  end
end
