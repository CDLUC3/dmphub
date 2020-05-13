class AddTitleToTechnicalResources < ActiveRecord::Migration[6.0]
  def change
    add_column :technical_resources, :title, :string, null: false, index: true
  end
end
