class CreateAwards < ActiveRecord::Migration[6.0]
  def change
    create_table :awards do |t|
      t.references  :project, index:true
      t.string      :funder_uri
      t.float       :amount
      t.string      :currency_type
      t.timestamps
    end
  end
end
