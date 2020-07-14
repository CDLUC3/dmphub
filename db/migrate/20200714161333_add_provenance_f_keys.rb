class AddProvenanceFKeys < ActiveRecord::Migration[6.0]
  def change
    add_reference :affiliations, :provenance, index: true
    add_reference :contributors, :provenance, index: true
    add_reference :contributors_data_management_plans, :provenance, index: true
    add_reference :costs, :provenance, index: true
    add_reference :data_management_plans, :provenance, index: true
    add_reference :datasets, :provenance, index: true
    add_reference :distributions, :provenance, index: true
    add_reference :fundings, :provenance, index: true
    add_reference :hosts, :provenance, index: true
    add_reference :identifiers, :provenance, index: true
    add_reference :licenses, :provenance, index: true
    add_reference :metadata, :provenance, index: true
    add_reference :projects, :provenance, index: true
    add_reference :security_privacy_statements, :provenance, index: true
    add_reference :technical_resources, :provenance, index: true
  end
end
