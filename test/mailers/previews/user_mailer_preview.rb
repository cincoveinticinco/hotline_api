# Preview all emails at http://localhost:3000/rails/mailers/user_mailer
class UserMailerPreview < ActionMailer::Preview
    def welcome
        user = User.find(1)
        UserMailer.email_token(user, "235003")
    end
end
