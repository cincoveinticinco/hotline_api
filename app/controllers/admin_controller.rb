class AdminController < ApplicationController
	before_action :validateToken

	def changeStatusreport
		Report.find(params['id']).update(r_status_id: params['status'])
		render :json => {
			:error => false,
			:msg => 'Report status succesfully changed'
		}
	end
	def addReportReply
		reply_txt = params['reply_txt']
		reply = RReply.find(params['id']) unless params['id'].blank?
		reply.update(reply_txt: reply_txt) unless params['id'].blank?

		RReply.create(report_id: params['report_id'], user_id: @user.id, reply_txt: reply_txt) if reply.blank?
		report = Report.find(params['report_id'])

		case params['action_status'].to_i
			when 1 then new_estatus = report.r_status_id
			when 2 then
				new_estatus = 4
				UserMailer.replyToUser(report, reply_txt).deliver_later if report.r_email
			when 3 then
				new_estatus = 6
		end
		report.update(r_status_id: new_estatus)

		render :json => {
			:error => false,
			:msg => 'Reply succesfully saved'
		}
	end
	def getUser
		render :json => {
			:error => false,
			:user => @user.id
		}
	end
	def DeleteReply
		text = 'Message deleted by user'
		reply = RReply.find(params['id'])
		report = Report.find(reply.report_id)
		text = 'Mesaje eliminado por el usuario' if report.language_id == 2
		text = 'Mensagem excluída pelo usuário' if report.language_id == 3
		reply.update(reply_txt: text)
		render :json => {
			:error => false,
			:msg => 'reply succesfully deleted'
		}
	end
	def listReports
		reports = Report.all_reports_list()
		centers = Center.all()
		incident_types = QOption.where(question_id: 10)
		projects = Project.all()
		report_statuses = RStatus.all()

		render :json => {
			:error => false,
			:reports => reports,
			:centers => centers,
			:incident_types => incident_types,
			:projects => projects,
			:report_statuses => report_statuses
		}
	end
	def getProjects
		projects = Project.getProjectList()
		centers = Center.all
		locations = Location.all
		render :json => {
			:error => false,
			:centers => centers,
			:locations => locations,
			:projects => projects
		}
	end	
	def newProject
		errors = []
		epr = nil
		if params['id'].blank?
			epr = Project.find_by(p_name: params['p_name'], p_season: params['p_season'], center_id: params['center_id'])
		end

		if !epr.blank?
			error = {
				msg_eng: 'This project already exists',
				msg_esp: 'Este proyecto ya existe',
				msg_prt: 'Este projeto já existe'
			}
			errors.push(error)
			render :json => {
				:error => true,
				:errors => errors
			}
		else
			if params['id'].blank?
				pr = Project.new
			else
				pr = Project.find(params['id'])
			end
			pr.p_name = params['p_name']
			pr.p_abbreviation = params['p_abbreviation']
			pr.p_season = params['p_season']
			pr.center_id = params['center_id']
			pr.location_id = checkLocation(params['location_name'])
			pr.production_company = params['production_company']
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
					exu = User.create(email: us, user_type_id:2, send_email:true)
					euhp = UserHasProject.create(user_id: exu.id, project_id:pr.id)
					# ACA DEBE MANDAR MAIL DE nuevo usurio
				elsif exu.user_type_id == 1
					error = {
						msg_eng: exu.email.to_s + ' ' + 'is a general user and cannot be added to this project',
						msg_esp: exu.email.to_s + ' ' + 'es un usuario general y no puede ser agregado al proyecto',
						msg_prt: exu.email.to_s + ' ' + 'é um usuário geral e não pode ser adicionado ao projeto'
					}
					errors.push(error)
				else
					euhp = UserHasProject.find_by(user_id: exu.id, project_id:pr.id)
					if euhp.blank?
						# ACA DEBE MANDAR MAIL DE nuevo usurio
						euhp = UserHasProject.create(user_id: exu.id, project_id:pr.id)
					end
				end
				users_added.push(euhp.id) unless euhp.blank?
			end
			UserHasProject.where(project_id: pr.id).where('id not in (?)', users_added).destroy_all
			UserHasProject.where(project_id: pr.id).destroy_all if users_added.length == 0
			ProjectAlias.where(project_id: pr.id).where('id not in (?)', alias_added).destroy_all
			ProjectAlias.where(project_id: pr.id).destroy_all if alias_added.length == 0
			if errors.length > 0
				render :json => {
					:error => true,
					:errors => errors
				}
			else
				render :json => {
					:error => false,
					:msg => 'project succesfully created'
				}
			end
		end
	end
	def getReportDetail
		report = Report.all_reports_list().where(id: params['report_id']).take
		answers = Answer.reportAnswers().where(report_id: params['report_id'])
		replies = RReply.reportReplies().select("users.email").where(report_id: params['report_id'])
		render :json => {
			:error => false,
			:report => report,
			:answers => answers,
			:replies => replies
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
			@user = User.where(email: decode_token["email"], token: decode_token["token"]).take
			if @user
				@user.token_last_update < 30.minutes.ago ? 
						(render :json => { :error => true, :msg => "Expired token" }) : 
						@user.update(token_last_update: DateTime.now)
			else
				render :json => { :error => true, :msg => "Invalid User" }
			end
		rescue => e
            render :json => { :error => true, :msg => "Decode Error: #{e}" }
		end
	end
end
