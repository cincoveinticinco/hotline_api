class CreateQTypes < ActiveRecord::Migration[6.1]
  def change
    create_table :q_types do |t|
      t.string :q_type_txt

      t.timestamps
    end
  end
end
