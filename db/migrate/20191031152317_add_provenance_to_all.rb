class AddProvenanceToAll < ActiveRecord::Migration[6.0]
  def change
    add_column :awards, :provenance, :string, index: true
    add_column :costs, :provenance, :string, index: true
    add_column :data_management_plans, :provenance, :string, index: true
    add_column :datasets, :provenance, :string, index: true
    add_column :distributions, :provenance, :string, index: true
    add_column :hosts, :provenance, :string, index: true
    add_column :licenses, :provenance, :string, index: true
    add_column :metadata, :provenance, :string, index: true
    add_column :organizations, :provenance, :string, index: true
    add_column :persons, :provenance, :string, index: true
    add_column :persons_data_management_plans, :provenance, :string, index: true
    add_column :persons_organizations, :provenance, :string, index: true
    add_column :projects, :provenance, :string, index: true
    add_column :security_privacy_statements, :provenance, :string, index: true
    add_column :technical_resources, :provenance, :string, index: true
  end
end
