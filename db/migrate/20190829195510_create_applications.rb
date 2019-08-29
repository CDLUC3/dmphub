class CreateApplications < ActiveRecord::Migration[6.0]
  def change
    create_table :applications do |t|
      t.string      :title, null: false
      t.integer     :category, null: false, default: 0
      t.string      :client_api_id, null: false
      t.string      :client_api_secret, null: false
      t.timestamps
    end
  end
end
