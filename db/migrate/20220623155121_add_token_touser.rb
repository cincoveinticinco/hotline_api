class AddTokenTouser < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :token, :string, :after => :email
    add_column :users, :token_last_update, :datetime, :after => :token
  end
end
