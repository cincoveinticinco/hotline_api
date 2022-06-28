class AddPAbbreviationToProjects < ActiveRecord::Migration[6.1]
  def change
    add_column :projects, :p_abbreviation, :string, :after => :p_name
  end
end
