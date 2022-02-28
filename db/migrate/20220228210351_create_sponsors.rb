class CreateSponsors < ActiveRecord::Migration[6.0]
  def change
    create_table :sponsors do |t|
      t.references  :data_management_plan, index: true
      t.string      :name, null: false, index: true
      t.integer     :name_type, null: false, default: 0, index: true
      t.timestamps
    end
  end
end
