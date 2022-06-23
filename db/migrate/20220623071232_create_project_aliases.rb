class CreateProjectAliases < ActiveRecord::Migration[6.1]
  def change
    create_table :project_aliases do |t|
      t.references :project, null: false, foreign_key: true
      t.string :p_alias

      t.timestamps
    end
  end
end
