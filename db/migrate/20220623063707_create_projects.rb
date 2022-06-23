class CreateProjects < ActiveRecord::Migration[6.1]
  def change
    create_table :projects do |t|
      t.string :p_name
      t.integer :p_season
      t.references :center, null: false, foreign_key: true

      t.timestamps
    end
  end
end
