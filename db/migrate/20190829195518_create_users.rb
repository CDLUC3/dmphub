# frozen_string_literal: true

class CreateUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :users do |t|
      t.references  :role, index: true
      t.string      :first_name
      t.string      :last_name
      t.string      :email, null: false, index: true
      t.text        :secret
      t.integer     :role, null: false, default: 0
      t.timestamps
    end
  end
end
