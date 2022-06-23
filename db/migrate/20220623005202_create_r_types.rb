class CreateRTypes < ActiveRecord::Migration[6.1]
  def change
    create_table :r_types do |t|
      t.string :r_type_txt

      t.timestamps
    end
  end
end
