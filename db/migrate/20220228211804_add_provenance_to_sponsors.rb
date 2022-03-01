class AddProvenanceToSponsors < ActiveRecord::Migration[6.0]
  def change
    add_reference :sponsors, :provenance, index: true
  end
end
