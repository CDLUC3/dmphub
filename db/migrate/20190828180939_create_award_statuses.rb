# frozen_string_literal: true

class CreateAwardStatuses < ActiveRecord::Migration[6.0]
  def change
    create_table :award_statuses do |t|
      t.references  :award, index: true
      t.integer     :status, null: false, default: 0
      t.timestamps
    end
  end
end
