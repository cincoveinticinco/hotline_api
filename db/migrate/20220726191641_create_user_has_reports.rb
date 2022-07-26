class CreateUserHasReports < ActiveRecord::Migration[6.1]
  def change
    create_table :user_has_reports do |t|
      t.references :user, null: false, foreign_key: {on_delete: :cascade, on_update: :cascade}
      t.references :report, null: false, foreign_key: {on_delete: :cascade, on_update: :cascade}

      t.timestamps
    end
  end
end
