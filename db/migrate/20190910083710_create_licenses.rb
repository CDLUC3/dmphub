# frozen_string_literal: true

class CreateLicenses < ActiveRecord::Migration[6.0]
  def change
    create_table :licenses do |t|
      t.references  :distribution, index: true
      t.string      :license_uri, null: false
      t.datetime    :start_date, null: false
      t.timestamps
    end
  end
end
