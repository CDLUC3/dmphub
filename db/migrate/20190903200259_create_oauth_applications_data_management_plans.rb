class CreateOauthApplicationsDataManagementPlans < ActiveRecord::Migration[6.0]
  def change
    create_table :oauth_authorizations do |t|
      t.references :oauth_application, index: true
      t.references :data_management_plan, index: true
      t.timestamps
    end
  end
end
