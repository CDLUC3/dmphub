class FixDistributionHostJoin < ActiveRecord::Migration[6.0]
  def change
    remove_column :hosts, :distribution_id
  end
end
