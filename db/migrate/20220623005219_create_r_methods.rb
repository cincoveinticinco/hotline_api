class CreateRMethods < ActiveRecord::Migration[6.1]
  def change
    create_table :r_methods do |t|
      t.string :r_method_txt

      t.timestamps
    end
  end
end
