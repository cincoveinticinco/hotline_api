class AdminController < ApplicationController
	before_action :validateToken

	def listReports
		reports = Report.all_reports_list()
		centers = Center.all()
		incident_types = QOption.where(question_id: 10)
		projects = Project.all()

		render :json => {
			:error => false,
			:reports => reports,
			:centers => centers,
			:incident_types => incident_types,
			:projects => projects
		}
	end
	def getProjects
		projects = Project.getProjectList()
		render :json => {
			:error => false,
			:projects => projects
		}
	end	
	def newProject
		errors = []
		if params['id'].blank?
			pr = Project.new
		else
			pr = Project.find(params['id'])
		end
		pr.p_name = params['p_name']
		pr.p_season = params['p_season']
		pr.center_id = params['center_id']
		pr.location_id = checkLocation(params['location_name'])
		pr.save
		alias_added = []
		users_added = []

		params['alias'].each do |al|
			tnal = ProjectAlias.find_by(project_id: pr.id, p_alias: al)
			tnal = ProjectAlias.create(project_id: pr.id, p_alias: al) if tnal.blank?
			alias_added.push(tnal.id)
		end unless params['alias'].blank?
		params['users'].each do |us|
			exu = User.find_by(email: us)
			if exu.blank?
				exu = User.create(email: us, user_type_id:1)
				exu = UserHasProject.create(user_id: exu.id, project_id:pr.id)
				
				# ACA DEBE MANDAR MAIL DE nuevo usurio
			elsif exu.user_type_id == 1
				msg = us.to_s + ' ' + 'is a General user and cannot be added to this project'
				errors.push(msg)
			else
				if UserHasProject.find_by(user_id: exu.id, project_id:pr.id).blank?
					# ACA DEBE MANDAR MAIL DE nuevo usurio
					UserHasProject.create(user_id: exu.id, project_id:pr.id)
				end

			end
			users_added.push(exu.id) unless exu.blank? 
		end

		UserHasProject.where(project_id: pr.id).where('id not in (?)', users_added).destroy_all
		UserHasProject.where(project_id: pr.id).destroy_all if users_added.length == 0
		ProjectAlias.where(project_id: pr.id).where('id not in (?)', alias_added).destroy_all
		ProjectAlias.where(project_id: pr.id).destroy_all if alias_added.length == 0


		render :json => {
			:error => false,
			:msg => 'project succesfully created'
		}
	end

	private
	def validateToken
		require 'jwt'
		header = request.headers['HTTP_AUTHORIZATION']
		pattern = /^Bearer /
		header = header.gsub(pattern, '') if header && header.match(pattern)
		begin
			decode_token = (JWT.decode header, Rails.application.credentials.secret_key_base, true, { algorithm: 'HS256' }).first
			user = User.where(email: decode_token["email"], token: decode_token["token"]).take
			if user
				user.token_last_update < 30.minutes.ago ? 
						(render :json => { :error => true, :msg => "Expired token" }) : 
						user.update(token_last_update: DateTime.now)
			else
				render :json => { :error => true, :msg => "Invalid User" }
			end
		rescue => e
            render :json => { :error => true, :msg => "Decode Error: #{e}" }
		end
	end
end
