class AddDataToUser < ActiveRecord::Migration[6.1]
  def change
    add_reference :users, :user_type, null: false, foreign_key: true, :after => :id
    add_column :users, :first_name, :string, :after => :user_type_id
    add_column :users, :last_name, :string, :after => :first_name
    
  end
end
