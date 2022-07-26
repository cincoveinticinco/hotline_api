class UserMailer < ApplicationMailer
    def email_token(user, token,language)
        change_language(language)
        subject = I18n.t :new_token
        htmlbody = render_to_string(:partial =>  'user_mailer/email_template.html.erb', :layout => false, :locals => { :token => token, :user => user })
        mails = []
        mails.push(user.email)
        send_email(mails, subject, htmlbody)
    end
    def followUpUser(email, report)
        reference = report.r_reference 
        language = Language.find report.language_id
        change_language(language.l_name)
        subject = (I18n.t :new_report_number) +reference.upcase.to_s
        htmlbody = render_to_string(:partial =>  'user_mailer/follow_up_user.html.erb', :layout => false, :locals => { :reference => reference })
        mails = []
        mails.push(email)
        send_email(mails, subject, htmlbody)
    end
    def replyToUser(report, txt)
        language = Language.find report.language_id
        change_language(language.l_name)

        subject = (I18n.t :report_number) +" "+report.r_reference.to_s.upcase+" "+ (I18n.t :response_hotline)
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
        subject = (I18n.t :user_replay) +" "+report.r_reference.upcase.to_s

        responses = RReply.reportReplies.where(report_id: report.id)
        incident = Answer.where(report_id: report.id, question_id: 13).take
        
        
        htmlbody = render_to_string(:partial =>  'user_mailer/reply_to_admin.html.erb', :layout => false, :locals => { :incident => incident, :responses => responses, :report_id=>report.id })
        mails = []
        bbc_mails = []
        users = UserHasProject.select('users.*').joins(:user).where('user_type_id = 2').where("send_email = true").where(project_id: report.project_id)
        if report.center_id.nil?
            users_center = User.where('user_type_id = 1').where("send_email = true")
        else
            users_center = User.allUsers.where('user_type_id = 1').where("send_email = true").where('center_id = ?', report.center_id)
        end
        
        if !users.blank?
            users.each do |user|
                mails.push(user['email'])
            end
        end
        users_center.each do |user|
            bbc_mails.push(user['email'])
        end
        
        mails = bbc_mails if mails.length == 0
        send_email(mails, subject, htmlbody,bbc_mails)
    end
    def newReportAdmin(report,send_reasign_user_id = nil)
        language = Language.find report.language_id
        change_language(language.l_name)

		report = Report.all_reports_list().where(id: report.id).take
        answers = Answer.reportAnswers().where(report_id: report.id)
        subject = I18n.t :new_incident
        subject = "#{ I18n.t :new_incident} - " + report.p_name unless report.p_name.blank?
        question_response = []
        cont = 1
        while cont <= 19
            question_response[cont] = answers.select{|an| an['question_id'].to_i == cont }.first
            cont +=1
        end
        htmlbody = render_to_string(:partial =>  'user_mailer/new_report_admin.html.erb', :layout => false, :locals => { :report => report, :question_response =>question_response })
        mails = []
        bbc_mails = []
        users = UserHasProject.select('users.*').joins(:user).where('user_type_id = 2').where("send_email = true").where(project_id: report.project_id)
        if report.center_id.nil?
            users_center = User.where('user_type_id = 1').where("send_email = true")
        else
            users_center = User.allUsers.where('user_type_id = 1').where("send_email = true").where('center_id = ?', report.center_id)
        end
        
        if !users.blank?
            users.each do |user|
                mails.push(user['email'])
            end
        end
        users_center.each do |user|
            bbc_mails.push(user['email'])
        end
        
        mails = bbc_mails if mails.length == 0
        unless send_reasign_user_id.nil?
            user_reasign = User.find(send_reasign_user_id)
            mails = []
            bbc_mails = []
            mails.push(user_reasign.email)
        end

        send_email(mails, subject, htmlbody, bbc_mails)
    end
    def sendEmailReports(email, reports, url)
        language = Language.find reports[0]['language_id']
        change_language(language.l_name)

        require 'jwt'
        subject = I18n.t :your_report
        links = []
        reports.each do |report|
            payload = { id: report['id'], reference: report['r_reference'], date: report['created_at']}
            report_consult = Report.find_by(r_reference: report['r_reference'])
            links.push( {link: encode_token_report(report_consult), data: payload })
        end
        htmlbody = render_to_string(:partial =>  'user_mailer/send_link_reports.html.erb', :layout => false, :locals => { :links => links, :url => url })
        send_email([email], subject, htmlbody)
    end

    def closeReport(report,reply_txt)
        language = Language.find report.language_id
        change_language(language.l_name)

        subject = (I18n.t :yo_have_close)
        htmlbody = render_to_string(:partial =>  'user_mailer/close_report.html.erb', :layout => false, :locals => { :reference => report.r_reference, :reply_txt =>reply_txt})
        mails = []
        mails.push(report.r_email)
        send_email(mails, subject, htmlbody) unless report.r_email.blank?


    end

    def underReviewnReport(report)
        language = Language.find report.language_id
        change_language(language.l_name)

        subject = (I18n.t :subjet_under_review)
        htmlbody = render_to_string(:partial =>  'user_mailer/under_review.html.erb', :layout => false, :locals => { :reference => report.r_reference })
        mails = []
        mails.push(report.r_email)
        send_email(mails, subject, htmlbody) unless report.r_email.blank?


    end
    private 
    def send_email (receiver, subject, htmlbody,bbc_mails = nil)
        # recibir bbc iy si no es nulo
        region = "us-west-2"
        encoding = "UTF-8"
        # configure SES session
        if Rails.env.development?
           
        else
            
        end

        ses = Aws::SES::Client.new(
            :region => region,
            :access_key_id => ACCES_KEY_ID,
            :secret_access_key => SECRET_ACCES_KEY
        )


  
        begin
            ses.send_email({
                destination: {
                    to_addresses: receiver,
                    bcc_addresses: bbc_mails
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
            else
                I18n.locale = :en
        end
        files_terms()
        
    end

    def files_terms()
        case I18n.locale.to_s
            when 'en'
               @file_term = "/public/HOTLINE_REPORT_LEGAL_TERMS.pdf"
               @file_policy = "/public/HOTLINE_REPORT_DATA_POLICY.pdf"
            when 'es'
                @file_term = "public/HOTLINE_REPORT_TERMINOS_LEGALES.pdf"
                @file_policy = "public/HOTLINE_REPORT_POLITICA_TRATAMIENTO_DATOS.pdf"
            when 'po'    
                @file_term = "/public/HOTLINE_REPORT_LEGAL_TERMS.pdf"
                @file_policy = "/public/HOTLINE_REPORT_DATA_POLICY.pdf"
            else
                @file_term = "/public/HOTLINE_REPORT_LEGAL_TERMS.pdf"
                @file_policy = "/public/HOTLINE_REPORT_DATA_POLICY.pdf"
        end
        
    end

    
end
