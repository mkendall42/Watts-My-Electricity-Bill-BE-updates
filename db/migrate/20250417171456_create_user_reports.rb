class CreateUserReports < ActiveRecord::Migration[7.1]
  def change
    create_table :user_reports do |t|
      t.references :user, null: false, foreign_key: true
      t.references :report, null: false, foreign_key: true

      t.timestamps
    end
  end
end
