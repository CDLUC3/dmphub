class RefactorTablesForNewRdaSchema < ActiveRecord::Migration[6.0]
  def change
    rename_table :organizations, :affiliations
    rename_table :persons, :contributors
    rename_table :awards, :fundings

    rename_index :persons_data_management_plans, :index_persons_data_management_plans_on_data_management_plan_id, :index_contribs_dmps
    rename_table :persons_data_management_plans, :contributors_data_management_plans
    rename_table :persons_organizations, :contributors_affiliations

    rename_column :licenses, :license_uri, :license_ref
    rename_column :fundings, :organization_id, :affiliation_id
    rename_column :contributors_data_management_plans, :person_id, :contributor_id
    rename_column :contributors_affiliations, :person_id, :contributor_id
    rename_column :contributors_affiliations, :organization_id, :affiliation_id

    add_column :hosts, :certified_with, :text
    add_column :hosts, :pid_system, :text
  end
end
