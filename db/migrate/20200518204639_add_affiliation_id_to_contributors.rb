class AddAffiliationIdToContributors < ActiveRecord::Migration[6.0]
  def change
    drop_table :contributors_affiliations

    add_reference :contributors, :affiliation, index: true
  end
end
