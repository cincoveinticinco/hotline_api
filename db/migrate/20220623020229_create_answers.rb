class CreateAnswers < ActiveRecord::Migration[6.1]
  def change
    create_table :answers do |t|
      t.references :question, null: false, foreign_key: true
      t.references :report, null: false, foreign_key: true
      t.string :a_txt
      t.boolean :a_yes_or_no
      t.references :q_option, foreign_key: true

      t.timestamps
    end
  end
end
