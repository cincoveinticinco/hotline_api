class AddShowReplayRReplay < ActiveRecord::Migration[6.1]
  def change
    add_column :r_replies, :show_replay, :boolean, :default => true, :after => :user_id
  end
end
