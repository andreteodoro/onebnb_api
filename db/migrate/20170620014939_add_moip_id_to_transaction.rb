class AddMoipIdToTransaction < ActiveRecord::Migration[5.0]
  def change
    add_column :transactions, :moip_id, :string
    add_reference :transactions, :card, foreign_key: true
  end
end
