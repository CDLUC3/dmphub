# frozen_string_literal: true

class CreateOrganizations < ActiveRecord::Migration[6.0]
  def change
    create_table :organizations do |t|
      t.string     :name, null: false, index: true
      t.timestamps
    end

    create_table :persons_organizations do |t|
      t.references :person, index: true
      t.references :organization, index: true
    end
  end
end
