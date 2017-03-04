class AddActiveToTalks < ActiveRecord::Migration[5.0]
  def change
    add_column :talks, :active, :boolean, :default => true
  end
end
