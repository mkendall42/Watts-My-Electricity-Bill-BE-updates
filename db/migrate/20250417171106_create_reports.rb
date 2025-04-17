class CreateReports < ActiveRecord::Migration[7.1]
  def change
    create_table :reports do |t|
      t.string :nickname
      t.float :energy_usage
      t.float :energy_cost

      t.timestamps
    end
  end
end
