class UserMailer < ApplicationMailer
    def email_token(user, token)
        subject = "HOTLINE TOKEN"
        htmlbody = render_to_string(:partial =>  'user_mailer/email_template.html.erb', :layout => false, :locals => { :token => token })
        mails = []
        mails.push(user.email)
        send_email(mails, subject, htmlbody)
    end
    def followUpUser(email, reference)
        subject = "Thanks for using Hotline Report"
        htmlbody = render_to_string(:partial =>  'user_mailer/follow_up_user.html.erb', :layout => false, :locals => { :reference => reference })
        mails = []
        mails.push(email)
        send_email(mails, subject, htmlbody)
    end
    def replyToUser(report, txt)
        subject = "TEST HOTLINE"
        incident = Answer.where(report_id: report.id, question_id: 13).take
        htmlbody = render_to_string(:partial =>  'user_mailer/reply_to_user.html.erb', :layout => false, :locals => { :txt => txt, :reference => report.r_reference, :incident => incident, })
        mails = []
        mails.push(report.r_email)
        send_email(mails, subject, htmlbody) unless report.r_email.blank?
    end
    def replyToAdmin(report)
        subject = "TEST HOTLINE"
        responses = RReply.reportReplies.where(report_id: report.id)
        incident = Answer.where(report_id: report.id, question_id: 13).take
        
        
        htmlbody = render_to_string(:partial =>  'user_mailer/reply_to_admin.html.erb', :layout => false, :locals => { :incident => incident, :responses => responses, :report_id=>report_id })
        mails = []
        users = User.where('user_type_id=1').where("send_email = true")
        users.each do |user|
            mails.push(user['email'])
        end
        if !report.project_id.blank?
            mails_project = UserHasProject.getUserProject(report.project_id)
            mails_project.each do |user|
                mails.push(user['email'])
            end
        end
        send_email(mails, subject, htmlbody)
    end
    def newReportAdmin(report)
        subject = "NEW INCIDENT REPORTED"
		report = Report.all_reports_list().where(id: report).take
        answers = Answer.reportAnswers().where(report_id: report.id)
        subject = "NEW INCIDENT REPORTED" + " - " + report.p_name unless report.p_name.blank?
        question_response = []
        cont = 1
        while cont <= 18
            question_response[cont] = answers.select{|an| an['question_id'].to_i == cont }.first
            cont +=1
        end
        htmlbody = render_to_string(:partial =>  'user_mailer/new_report_admin.html.erb', :layout => false, :locals => { :report => report, :question_response =>question_response })
        mails = []
        users = User.where('user_type_id = 1').where("send_email = true")
        users.each do |user|
            mails.push(user['email'])
        end
        if !report.project_id.blank?
            mails_project = UserHasProject.getUserProject(report.project_id)
            mails_project.each do |user|
                mails.push(user['email'])
            end
        end
        
        send_email(mails, subject, htmlbody)
    end
    private 
    def send_email (receiver, subject, htmlbody)
        region = "us-west-2"
        encoding = "UTF-8"
        # configure SES session
        if Rails.env.development?
            ses = Aws::SES::Client.new(
                :region => region,
                :access_key_id => ACCES_KEY_ID,
                :secret_access_key => SECRET_ACCES_KEY
            )
        else
            ses = Aws::SES::Client.new(
                region: region
            )
        end


  
        begin
            ses.send_email({
                destination: {
                    to_addresses: receiver,
                },
                message: {
                    body: {
                        html: {
                            charset: encoding,
                            data: htmlbody,
                        }
                    },
                    subject: {
                        charset: encoding,
                        data: subject,
                    },
                },
                source: "no-reply@onewrapp.com",
            })
            puts "Email sent!"
        rescue Aws::SES::Errors::ServiceError => error
            puts "Email not sent. Error message: #{error}"
        end
    end
end
