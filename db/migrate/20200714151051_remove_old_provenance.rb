class RemoveOldProvenance < ActiveRecord::Migration[6.0]
  def change
    remove_column :affiliations, :provenance
    remove_column :contributors, :provenance
    remove_column :contributors_data_management_plans, :provenance
    remove_column :costs, :provenance
    remove_column :data_management_plans, :provenance
    remove_column :datasets, :provenance
    remove_column :distributions, :provenance
    remove_column :fundings, :provenance
    remove_column :hosts, :provenance
    remove_column :identifiers, :provenance
    remove_column :licenses, :provenance
    remove_column :metadata, :provenance
    remove_column :projects, :provenance
    remove_column :security_privacy_statements, :provenance
    remove_column :technical_resources, :provenance
  end
end
