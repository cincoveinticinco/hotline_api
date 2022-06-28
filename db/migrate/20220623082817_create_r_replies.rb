class CreateRReplies < ActiveRecord::Migration[6.1]
  def change
    create_table :r_replies do |t|
      t.references :report, null: false, foreign_key: true
      t.references :user, null: true, foreign_key: true
      t.string :reply_txt

      t.timestamps
    end
  end
end
