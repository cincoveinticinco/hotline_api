class CreateQOptions < ActiveRecord::Migration[6.1]
  def change
    create_table :q_options do |t|
      t.references :question, null: false, foreign_key: true
      t.string :q_option_title
      t.string :q_option_txt
      t.integer :q_option_order

      t.timestamps
    end
  end
end
