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
        send_email(email, subject, htmlbody)
    end
    def replyToUser(report, txt)
        subject = "Welcome email"
        htmlbody = render_to_string(:partial =>  'user_mailer/reply_to_user.html.erb', :layout => false, :locals => { :txt => txt, :reference => report.r_reference })
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
		data = Report.all_reports_list().where(id: report).take
        htmlbody = render_to_string(:partial =>  'user_mailer/new_report_admin.html.erb', :layout => false, :locals => { :data => data })
        send_email(report.r_email, subject, htmlbody)
    end
    def sendEmailReports(reports)
        subject = "Welcome email"
        htmlbody = render_to_string(:partial =>  'user_mailer/send_link_reports.html.erb', :layout => false, :locals => { :reports => reports })
        send_email(report.r_email, subject, htmlbody)
    end
    private 
    def send_email (receiver, subject, htmlbody)
        region = "us-west-2"
        encoding = "UTF-8"
        # configure SES session
        ses = Aws::SES::Client.new(
            region: region
        )
        begin
            ses.send_email({
                destination: {
                    to_addresses: [
                    receiver,
                    ],
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
