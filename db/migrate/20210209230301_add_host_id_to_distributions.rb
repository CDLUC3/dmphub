class AddHostIdToDistributions < ActiveRecord::Migration[6.0]
  def change
    add_reference :distributions, :host, index: true
  end
end
