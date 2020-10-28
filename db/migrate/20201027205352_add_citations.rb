class AddCitations < ActiveRecord::Migration[6.0]
  def change
    create_table :citations do |t|
      t.references :identifier, index: true, null: false
      t.references :provenance, index: true, null: false
      t.integer :object_type, index: true, null: false, default: 0
      t.text :citation_text
      t.json :original_json
      t.datetime :retrieved_on, index: true, null: false
      t.timestamps null: false
    end
  end
end
