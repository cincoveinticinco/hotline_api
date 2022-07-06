class AddProductionCompanyToProject < ActiveRecord::Migration[6.1]
  def change
    add_column :projects, :production_company, :string, :after => :id
  end
end
