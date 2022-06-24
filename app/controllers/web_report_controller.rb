class WebReportController < ApplicationController
	def submitAnswer
		answers = params['answers']
		if params['report_id'].blank?
			# set default type hotline, default status Started, method online
			rp = Report.create(r_type_id: 1, r_status_id: 1, r_method_id: 1)
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
			# Creates reference number for followup
			rp.update(r_reference: SecureRandom.hex(10), r_status_id: 2) if qt.id == 18 and rp.r_reference.nil?

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
		rp.update(r_password: params['password'])
		render :json => {
			:error => false,
			:msg => 'Password succesfully saved'
		}
	end
	
end
