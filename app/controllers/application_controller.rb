class ApplicationController < ActionController::API

	
	def checkLocation(info)
		el = Location.find_by(location_name: info)
		el = Location.create(location_name: info) if el.blank?

		return el.id
	end

	def uploadFileToS3(file, folder)
	    require 's3_store'
	    route = nil
	    if !file.blank?
	      	new_name = File.basename(file.original_filename, ".*")
	      	new_name = new_name.gsub(':', '').gsub('-', '') + '_' + Time.now.to_s(:number) + File.extname(file.original_filename)
	      	file.original_filename = new_name 
        	S3Store.new(file,"#{folder}").store
	        route = "#{folder}" + '/' + file.original_filename
	    end
	    return route

		
  	end

	def signAwsS3Url(file_name)
	  return nil if file_name.blank?

	  client = Aws::S3::Client.new(
		:region => REGION,
		:access_key_id => ACCES_KEY_ID,
		:secret_access_key => SECRET_ACCES_KEY
	  )
	  signer = Aws::S3::Presigner.new client: client
	  return signer.presigned_url(:get_object,bucket: BUCKET, key: file_name.to_s, expires_in: 604799)
	end




end
