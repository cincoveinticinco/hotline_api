class PasswordDigest < ActiveRecord::Migration[6.1]
  def change
    remove_column :reports, :r_password
    add_column :reports, :password_digest, :string, :after => :r_reference
    add_column :reports, :token_last_update, :datetime, :after => :password_digest
  end
end
