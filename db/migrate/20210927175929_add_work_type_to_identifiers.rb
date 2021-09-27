class AddWorkTypeToIdentifiers < ActiveRecord::Migration[6.0]
  def change
    add_column :identifiers, :work_type, :integer, index: true
  end
end
