class AddProvenanceToAwardStatuses < ActiveRecord::Migration[6.0]
  def change
    add_column :award_statuses, :provenance, :string, index: true, null: false
  end
end
