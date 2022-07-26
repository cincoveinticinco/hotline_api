class AdminController < ApplicationController
	before_action :validateToken, except: [ :getQrCode ]

	def deleteProject
		ProjectAlias.where(project_id: params['id']).destroy_all
		UserHasProject.where(project_id: params['id']).destroy_all
		Project.find(params['id']).destroy
		
		render :json => {
			:error => false,
			:msg => 'Project succesfully deleted'
		}
	end
	def changeStatusreport
		Report.find(params['id']).update(r_status_id: params['status'])
		report = Report.find(params['id'])
		UserMailer.underReviewnReport(report).deliver_later if report.r_email
		render :json => {
			:error => false,
			:msg => 'Report status succesfully changed'
		}
	end
	def addReportReply
		reply_txt = params['reply_txt']
		reply = RReply.find(params['id']) unless params['id'].blank?
		reply = RReply.new if params['id'].blank?
		reply.reply_txt = reply_txt
		reply.user_id = @user.id
		reply.report_id = params['report_id']
		reply.show_replay = false if params['action_status'].to_i == 1
		reply.save
		

		report = Report.find(params['report_id'])

		case params['action_status'].to_i
			when 1 then new_estatus = report.r_status_id
			when 2 then
				new_estatus = 4
				UserMailer.replyToUser(report, reply_txt).deliver_later if report.r_email
			when 3 then
				new_estatus = 6
				UserMailer.closeReport(report,reply_txt).deliver_later if report.r_email
				# here we need to send the report ticket is closed
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
			:user => @user.id,
			:user_type_id => @user.user_type_id,
			:confidentiality_notice => @user.confidentiality_notice,
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
		if @user.user_type_id == 1
			reports = Report.all_reports_list().where("center_id in (?)", @ass_centers)
			centers = Center.where("id in (?)", @ass_centers)
			projects = Project.where("center_id in (?)", @ass_centers)
		elsif @user.user_type_id == 2
			reports = Report.all_reports_list().where("reports.project_id in (?)", @ass_projects)
			centers = nil
			projects =  Project.where("id in (?)", @ass_projects)
		end
		
		
		incident_types = QOption.where(question_id: 10)
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
		projects = Project.getProjectList().where("projects.center_id in (?)", @ass_centers) if @user.user_type_id == 1
		projects = Project.getProjectList().where("projects.center_id in (?)", @project_center_ids) if @user.user_type_id == 2
		centers = Center.where("id in (?)", @ass_centers) if @user.user_type_id == 1
		centers = Center.where("id in (?)", @project_center_ids) if @user.user_type_id == 2
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
		answers.each do |answer|
			 if answer['q_type_id'] == 6
				answer['a_txt'] = signAwsS3Url(answer['a_txt'])
			 end
		end
		
		replies = RReply.reportReplies().select("users.email").where(report_id: params['report_id'])
		render :json => {
			:error => false,
			:report => report,
			:answers => answers,
			:replies => replies
		}
	end
	def getQrCode
		require "rqrcode"
		id = params[:id]
		abbreviation = params[:abbreviation]
        project = Project.find_by(id: params[:id], p_abbreviation: abbreviation)
        url = "https://hotline.report/home/#{project.p_abbreviation}"
        qrcode = RQRCode::QRCode.new(url)
        project.p_abbreviation
        png = qrcode.as_png(
            bit_depth: 1,
            border_modules: 4,
            color_mode: ChunkyPNG::COLOR_GRAYSCALE,
            color: "black",
            file: nil,
            fill: "white",
            module_px_size: 6,
            resize_exactly_to: false,
            resize_gte_to: false,
            size: 120
          )
        route = "tmp/qrcode.png"
        IO.binwrite(route, png.to_s)
        send_file(route, filename: "qrcode-#{project.p_name.gsub(' ', '_')}.png", type: "image/png")
	end

	def accept_confidentiality_notice
		@user.update(confidentiality_notice: true)
		render :json => {
			:error => false,
			:msg => 'successful',
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
						ass_centers = UserHasCenter.select("group_concat(center_id)ids").where(user_id: @user.id).take if @user.user_type_id == 1
						@ass_centers = ass_centers.ids.split(",").map(&:to_i) if @user.user_type_id == 1
						ass_projects = UserHasProject.select("group_concat(project_id)ids").where(user_id: @user.id).take if @user.user_type_id == 2
						@ass_projects = ass_projects.ids.split(",").map(&:to_i) if @user.user_type_id == 2
						@project_centers = Project.select('group_concat(center_id) as ids').where("id in (?)", @ass_projects).take if @user.user_type_id == 2
						@project_center_ids = @project_centers.ids.split(",").map(&:to_i) if @user.user_type_id == 2
			else
				render :json => { :error => true, :msg => "Invalid User" }
			end
		rescue => e
            render :json => { :error => true, :msg => "Decode Error: #{e}" }
		end
	end
end
