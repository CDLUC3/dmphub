class CreateIdentifiers < ActiveRecord::Migration[6.0]
  def change
    create_table :identifiers do |t|
      t.string      :value, null: false
      t.integer     :category, null: false, index: true, default: 0
      t.bigint      :identifiable_id
      t.string      :identifiable_type
      t.timestamps
    end
  end
end
