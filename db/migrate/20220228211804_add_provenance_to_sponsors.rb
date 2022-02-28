class AddProvenanceToSponsors < ActiveRecord::Migration[6.0]
  def change
    add_column :sponsors, :provenance, :string, index: true
  end
end
