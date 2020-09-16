class AddFundedAffiliationsToFundings < ActiveRecord::Migration[6.0]
  def change
    create_table :fundings_affiliations, id: false do |t|
      t.bigint :funding_id, index: true
      t.bigint :affiliation_id, index: true
    end
  end
end
