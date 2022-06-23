class ApplicationController < ActionController::API
<<<<<<< HEAD
	# before_action :authorize_request
=======
>>>>>>> d1e176c975d8ede7637f304239141a8bb66f174e
	
	def checkLocation(info)
		el = Location.find_by(location_name: info)
		el = Location.create(location_name: info) if el.blank?

		return el.id
	end
end
