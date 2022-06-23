class CreateCenters < ActiveRecord::Migration[6.1]
  def change
    create_table :centers do |t|
      t.string :center_name

      t.timestamps
    end
  end
end
