class UserMailer < ApplicationMailer
    def email_token(user, token)
        receiver = user.email
        subject = "Report email"
        htmlbody = render_to_string(:partial =>  'user_mailer/email_template.html.erb', :layout => false, :locals => { :token => token })
        send_email(receiver, subject, htmlbody)
    end
    def followUpUser(email, reference)
        subject = "Welcome email"
        htmlbody = render_to_string(:partial =>  'user_mailer/follow_up_user.html.erb', :layout => false, :locals => { :reference => reference })
        mails = []
        mails.push(email)
        send_email(mails, subject, htmlbody)
    end
    def replyToUser(report, txt)
        subject = "Welcome email"
        incident = Answer.where(report_id: report.id, question_id: 13).take
        htmlbody = render_to_string(:partial =>  'user_mailer/reply_to_user.html.erb', :layout => false, :locals => { :txt => txt, :reference => report.r_reference, :incident => incident, })
        send_email(report.r_email, subject, htmlbody)
    end
    def replyToAdmin(report)
        subject = "Welcome email"
        responses = RReply.reportReplies.where(report_id: report.id)
        incident = Answer.where(report_id: report.id, question_id: 13).take
        
       
        htmlbody = render_to_string(:partial =>  'user_mailer/reply_to_admin.html.erb', :layout => false, :locals => { :incident => incident, :responses => responses })
        send_email(report.r_email, subject, htmlbody)
    end
    def newReportAdmin(report)
        subject = "Welcome email"
		report = Report.all_reports_list().where(id: report).take
        answers = Answer.reportAnswers().where(report_id: report.id)
        question_response = []
        cont = 1
        while cont <= 18
            question_response[cont] = answers.select{|an| an['question_id'].to_i == cont }.first
            cont +=1
        end
        htmlbody = render_to_string(:partial =>  'user_mailer/new_report_admin.html.erb', :layout => false, :locals => { :report => report, :question_response =>question_response })
        mails = []
        users = User.where('user_type_id=1')
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
