class AddApiClients < ActiveRecord::Migration[6.0]
  def change
    create_table :api_clients do |t|
      t.string :name, null: false, index: true
      t.string :description
      t.string :homepage
      t.string :contact_name
      t.string :contact_email, null: false
      t.string :client_id, null: false
      t.string :client_secret, null: false
      t.date   :last_access
      t.timestamps null: false
    end

    create_table :api_client_permissions do |t|
      t.references :api_client, index: true, null: false
      t.integer :permission, null: false
      t.text :rule
      t.timestamps null: false
    end

    create_table :api_client_histories do |t|
      t.references :api_client, index: true, null: false
      t.references :data_management_plan, index: true, null: false
      t.integer :type
      t.text :description
      t.timestamps null: false
    end

    create_table :api_client_authorizations do |t|
      t.references :api_client, index: true, null: false
      t.integer :authorizable_id, null: false
      t.string :authorizable_type, null: false
      t.timestamps null: false
    end
  end
end
