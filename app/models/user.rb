class User < ApplicationRecord
	def self.allUsers()
		User.select("users.id, users.first_name, users.last_name, users.user_type_id, users.email, users.send_email, users.token, users.token_last_update")
		.joins("left join user_has_centers ON user_has_centers.user_id = users.id")
	end
end
