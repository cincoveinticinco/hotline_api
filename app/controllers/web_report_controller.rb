class WebReportController < ApplicationController

	def getProjectName
		p_info = params['project'].split('-')
		if p_info.length > 1
			project = Project.find_by(:p_abbreviation => p_info[0], :p_season => p_info[1])
		else
			project = Project.find_by(:p_abbreviation => p_info[0])
		end
		
		if project.blank?
			render :json => {
				:error => false,
				:p_name => nil,
				:p_season => nil
			}
		else
			render :json => {
				:error => false,
				:p_name => project.p_name,
				:p_season => project.p_season
			}
		end
	end
	def submitAnswer
		answers = params['answers']
		language = params['lang'].blank? ? 1 : params['lang']
		if params['report_id'].blank?
			# set default type hotline, default status Started, method online
			rp = Report.create(r_type_id: 1, r_status_id: 1, r_method_id: 1, language_id:language)
			
		else
			rp = Report.find(params['report_id'])
		end
		answers.each do |a|
			qt = Question.find(a['question_id'])
			anw = Answer.find_by(:report_id => rp.id, :question_id => qt.id)
			anw = Answer.create(report_id: rp.id, question_id: qt.id) if anw.blank?

			anw.a_txt = a['answer'] if qt.q_type_id == 1  || (qt.q_type_id == 3 && a['a_yes_or_no'] == true)
			anw.a_yes_or_no = a['a_yes_or_no'] if qt.q_type_id == 2 || qt.q_type_id == 3
			anw.q_option_id	= a['q_option_id'] if qt.q_type_id == 4
			anw.save
			rp.update(r_email: a['answer']) if qt.id == 5
			if qt.id == 18 and rp.r_reference.nil?
				rp.update(r_reference: SecureRandom.hex(5), r_status_id: 2)
				answers_proj = Answer.where(report_id: rp.id).where("question_id IN (?)", [11, 12])
				name = answers_proj.select { |obj| obj.question_id == 11 }.first
				season = answers_proj.select { |obj| obj.question_id == 12 }.first
				if name && season
					project = Project.where("p_name = ? AND p_season = ?", name.a_txt, season.a_txt).take
					rp.update(project_id: project.id) if project
				elsif name
					project = Project.where("p_name = ?", name.a_txt).take
					rp.update(project_id: project.id) if project
				end
				UserMailer.followUpUser(rp.r_email, rp.r_reference).deliver_later if rp.r_email
				UserMailer.newReportAdmin(rp).deliver_later
			end
		end

		render :json => {
			:error => false,
			:msg => 'Answer succesfully saved',
			:report_id => rp.id,
			:report_followup => rp.r_reference	
		}
	end
	

	def createPassword
		rp = Report.find_by(id: params['report_id'],r_reference: params['report_followup'] )
		rp.update(password: params['password'])
		render :json => {
			:error => false,
			:msg => 'Password succesfully saved'
		}
	end
	def sendEmailToken
		reports = Report.where(r_email: params[:email]).as_json
		unless reports.empty?
			url = request.protocol + request.host_with_port
			UserMailer.sendEmailReports(params[:email], reports, url).deliver_later
			render :json => {
				:error => false,
				:msg => 'Email succesfully sended'
			}
		else
			render :json => {
				:error => true,
				:msg => 'Email not found'
			}
		end
	end
end