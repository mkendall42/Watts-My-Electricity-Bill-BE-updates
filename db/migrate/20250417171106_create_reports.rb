class CreateReports < ActiveRecord::Migration[7.1]
  def change
    create_table :reports do |t|
      t.string :nickname
      t.float :energy_consumption
      t.float :energy_cost
      t.string :state

      t.float :state_residential_avg
      t.float :state_industrial_avg
      t.float :state_commercial_avg

      t.float :zip_residential_avg
      t.float :zip_industrial_avg
      t.float :zip_commercial_avg

      t.timestamps
    end
  end
end
