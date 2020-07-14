class SwicthOrgToAffiliationOnUsers < ActiveRecord::Migration[6.0]
  def change
    remove_reference :users, :organization
    add_reference :users, :affiliation, index: true
  end
end
