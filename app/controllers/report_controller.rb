class ReportController < ApplicationController
	before_action :validateToken
	def infoReport
		report = Report.all_reports_list.where(id: @report.id).take
		answers = Answer.reportAnswers.where(report_id: @report.id)
		answers.each do |answer|
			if answer['q_type_id'] == 6
			   a['a_txt'] = signAwsS3Url(a['a_txt'])
			end
	   end
		replies = RReply.reportReplies().where(report_id: @report.id).where('show_replay is true')
		render :json => {
			:error => false,
			:report => report,
			:answers => answers,
			:replies => replies
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
    def replyReport
		report = Report.find @report.id
		report.r_status_id = 5
		report.save
        RReply.create(report_id: @report.id, reply_txt: params[:reply_txt]) unless params[:id]
		RReply.find(params[:id]).update(reply_txt: params[:reply_txt]) if params[:id]
		UserMailer.replyToAdmin(@report).deliver_later
        render :json => { :error => false, :msg => 'Reply succesfully saved' }
    end
	def deleteReply
		RReply.find(params[:id]).destroy
        render :json => { :error => false, :msg => 'Reply succesfully deleted' }
	end
	

    private
	def validateToken
		require 'jwt'
		header = request.headers['HTTP_AUTHORIZATION']
		pattern = /^Bearer /
		header = header.gsub(pattern, '') if header && header.match(pattern)
		begin
			decode_token = (JWT.decode header, Rails.application.credentials.secret_key_base, true, { algorithm: 'HS256' }).first
			@report = Report.where(id: decode_token["id"], r_reference: decode_token["reference"]).take
			if @report
				@report.token_last_update < 30.minutes.ago ? 
						(render :json => { :error => true, :msg => "Expired token" }) : 
						@report.update(token_last_update: DateTime.now)
			else
				render :json => { :error => true, :msg => "Invalid report" }
			end
		rescue => e
            render :json => { :error => true, :msg => "Decode Error: #{e}" }
		end
	end
end
