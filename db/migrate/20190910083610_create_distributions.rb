# frozen_string_literal: true

class CreateDistributions < ActiveRecord::Migration[6.0]
  def change
    create_table :distributions do |t|
      t.references  :dataset, index: true
      t.string      :title, null: false
      t.longtext    :description
      t.string      :format
      t.float       :byte_size
      t.string      :access_url
      t.string      :download_url
      t.integer     :data_access
      t.datetime    :available_until
      t.timestamps
    end
  end
end
