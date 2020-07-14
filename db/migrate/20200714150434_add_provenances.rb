class AddProvenances < ActiveRecord::Migration[6.0]
  def change
    create_table :provenances do |t|
      t.string :name, null: false, index: true
      t.string :description
      t.timestamps null: false
    end
    create_table :alterations do |t|
      t.references :provenance, index: true, null: false
      t.bigint :alteration_id, null: false
      t.string :alteration_type, null: false
      t.text :changes, null: false
      t.timestamps null: false
      t.index [:alteration_id, :alteration_type], name: "index_provenance_alterations_on_id_type"
    end
  end
end
