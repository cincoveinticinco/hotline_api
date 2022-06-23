class CreateReports < ActiveRecord::Migration[6.1]
  def change
    create_table :reports do |t|
      t.references :r_type, null: false, foreign_key: true
      t.references :r_method, null: false, foreign_key: true
      t.references :r_status, null: false, foreign_key: true
      t.string :r_email
      t.string :r_reference
      t.string :r_password

      t.timestamps
    end
  end
end
