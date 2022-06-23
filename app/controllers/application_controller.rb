class ApplicationController < ActionController::API
	
	def checkLocation(info)
		el = Location.find_by(location_name: info)
		el = Location.create(location_name: info) if el.blank?

		return el.id
	end
end
