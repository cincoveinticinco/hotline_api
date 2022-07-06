class ReportController < ApplicationController
	before_action :validateToken
	def infoReport
		report = Report.all_reports_list.where(id: @report.id).take
		answers = Answer.reportAnswers.where(report_id: @report.id)
		replies = RReply.reportReplies().where(report_id: @report.id)
		render :json => {
			:error => false,
			:report => report,
			:answers => answers,
			:replies => replies
		}
	end
    def replyReport
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
