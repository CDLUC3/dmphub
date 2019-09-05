class AddProvenanceToIdentifiers < ActiveRecord::Migration[6.0]
  def change
    add_column :identifiers, :provenance, :string, index: true, null: false
  end
end
