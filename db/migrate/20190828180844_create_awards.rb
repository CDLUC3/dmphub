# frozen_string_literal: true

class CreateAwards < ActiveRecord::Migration[6.0]
  def change
    create_table :awards do |t|
      t.references  :project, index: true
      t.string      :funder_uri, index: true
      t.integer     :status, null: false, default: 0, index: true
      t.timestamps
    end
  end
end
