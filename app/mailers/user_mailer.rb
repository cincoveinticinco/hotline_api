class UserMailer < ApplicationMailer
    def email_token(user, token,language)
        change_language(language)
        subject = "HOTLINE TOKEN"
        htmlbody = render_to_string(:partial =>  'user_mailer/email_template.html.erb', :layout => false, :locals => { :token => token, :user => user })
        mails = []
        mails.push(user.email)
        send_email(mails, subject, htmlbody)
    end
    def followUpUser(email, report)
        reference = report.r_reference 
        language = Language.find report.language_id
        change_language(language.l_name)
        subject = I18n.t :thanks
        htmlbody = render_to_string(:partial =>  'user_mailer/follow_up_user.html.erb', :layout => false, :locals => { :reference => reference })
        mails = []
        mails.push(email)
        send_email(mails, subject, htmlbody)
    end
    def replyToUser(report, txt)
        language = Language.find report.language_id
        change_language(language.l_name)

        subject = "TEST HOTLINE"
        incident = Answer.where(report_id: report.id, question_id: 13).take
        htmlbody = render_to_string(:partial =>  'user_mailer/reply_to_user.html.erb', :layout => false, :locals => { :txt => txt, :reference => report.r_reference, :incident => incident, })
        mails = []
        mails.push(report.r_email)
        send_email(mails, subject, htmlbody) unless report.r_email.blank?
    end
    def replyToAdmin(report_send)
        language = Language.find report_send.language_id
        change_language(language.l_name)

        report = Report.all_reports_list().where(id: report_send.id).take
        subject = "TEST HOTLINE"

        responses = RReply.reportReplies.where(report_id: report.id)
        incident = Answer.where(report_id: report.id, question_id: 13).take
        
        
        htmlbody = render_to_string(:partial =>  'user_mailer/reply_to_admin.html.erb', :layout => false, :locals => { :incident => incident, :responses => responses, :report_id=>report.id })
        mails = []
        # 
        if report.center_id.nil?
            users = User.allUsers().where('user_type_id = 1').where("send_email = true")
        else
            users = UserHasCenter.get_all(center_id)
        end
        
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
        language = Language.find report.language_id
        change_language(language.l_name)

		report = Report.all_reports_list().where(id: report).take
        answers = Answer.reportAnswers().where(report_id: report.id)
        subject = I18n.t :new_incident
        subject = "#{ I18n.t :new_incident} - " + report.p_name unless report.p_name.blank?
        question_response = []
        cont = 1
        while cont <= 18
            question_response[cont] = answers.select{|an| an['question_id'].to_i == cont }.first
            cont +=1
        end
        htmlbody = render_to_string(:partial =>  'user_mailer/new_report_admin.html.erb', :layout => false, :locals => { :report => report, :question_response =>question_response })
        mails = []
        bbc_mails = []
        users = UserHasProject.joins(:user).where('user_type_id = 2').where("send_email = true").where(project_id: report.project_id)
        if report.center_id.nil?
            users_center = User.where('user_type_id = 1').where("send_email = true")
        else
            users_center = User.allUsers.where('user_type_id = 1').where("send_email = true").where('center_id = ?', report.center_id)
        end
        
        users.each do |user|
            mails.push(user['email'])
        end
        users_center.each do |user|
            bbc_mails.push(user['email'])
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
    def sendEmailReports(email, reports, url)
        language = Language.find reports[0]['language_id']
        change_language(language.l_name)

        require 'jwt'
        subject = "Welcome email"
        links = []
        reports.each do |report|
            payload = { id: report['id'], reference: report['r_reference']}
            links.push(JWT.encode(payload, Rails.application.credentials.secret_key_base, 'HS256'))
        end
        htmlbody = render_to_string(:partial =>  'user_mailer/send_link_reports.html.erb', :layout => false, :locals => { :links => links, :url => url })
        send_email([email], subject, htmlbody)
    end
    private 
    def send_email (receiver, subject, htmlbody)
        # recibir bbc iy si no es nulo
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

    def change_language(len)
        case len.to_s
            when 'English'
                I18n.locale = :en
            when 'Spanish'
                I18n.locale = :es
            when 'Portugues'    
                I18n.locale = :po
        end
        
    end

    
end
