class AddSendEmailToUser < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :send_email, :boolean, :default => false, :after => :email
  end
end
