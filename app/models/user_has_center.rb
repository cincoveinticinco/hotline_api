class UserHasCenter < ApplicationRecord
  belongs_to :user
  belongs_to :center

  def self.get_all(center_id)
  	UserHasCenter.select("users.*")
  	.joins(:user)
  	.where('user_has_centers.center_id = ?', center_id)
  	
  end
end
