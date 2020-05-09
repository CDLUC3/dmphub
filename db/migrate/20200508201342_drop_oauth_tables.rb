class DropOauthTables < ActiveRecord::Migration[6.0]
  def change
    drop_table :oauth_access_grants
    drop_table :oauth_access_tokens
    drop_table :oauth_application_profiles
    drop_table :oauth_authorizations
    drop_table :oauth_applications
  end
end
