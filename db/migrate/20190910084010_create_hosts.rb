# frozen_string_literal: true

class CreateHosts < ActiveRecord::Migration[6.0]
  def change
    create_table :hosts do |t|
      t.references  :distribution, index: true
      t.string      :title, null: false
      t.longtext    :description
      t.boolean     :supports_versioning
      t.string      :backup_type
      t.string      :backup_frequency
      t.string      :storage_type
      t.string      :availability
      t.string      :geo_location
      t.timestamps
    end
  end
end
