class UserMailer < ApplicationMailer
    def email_token(user, token)
        receiver = user.email
        sender = "no-reply@onewrapp.com"
        subject = "Welcome email"
        # The HTML body of the email
        htmlbody = render_to_string(:partial =>  'user_mailer/email_template.html.erb', :layout => false, :locals => { :token => token })
        # send email
        send_email(receiver, sender, subject, htmlbody)
    end


    private 
    def send_email (receiver, sender, subject, htmlbody)
        region = "us-west-2"
        # Specify the text encoding scheme.
        encoding = "UTF-8"
        # configure SES session
        ses = Aws::SES::Client.new(
            region: region
            # access_key_id: "XXXXXXXXXX", 
            # secret_access_key: "XXXXXXXXXXXXXXXXXXXXX"
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
                source: sender,
            })
            puts "Email sent!"
        rescue Aws::SES::Errors::ServiceError => error
            puts "Email not sent. Error message: #{error}"
        end
    end
end
