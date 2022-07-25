class AddConfidentialityNoticeToUser < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :confidentiality_notice, :boolean, :default => false, :after => :token
  end
end
