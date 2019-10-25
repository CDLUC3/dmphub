class CreateOauthApplicationProfiles < ActiveRecord::Migration[6.0]
  def change
    create_table :oauth_application_profiles do |t|
      t.references :oauth_application, index: true
      t.integer :permissions, null: false, default: 0, index: true
      t.text :rules, :json
    end
  end
end
