class CreateQuestions < ActiveRecord::Migration[6.1]
  def change
    create_table :questions do |t|
      t.references :r_type, null: false, foreign_key: true
      t.references :q_type, null: false, foreign_key: true
      t.string :q_title
      t.string :q_txt

      t.timestamps
    end
  end
end
