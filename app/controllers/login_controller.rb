class LoginController < ApplicationController
    require 'jwt'
    require 'date'
    require 'uri'
    require 'net/http'
    include ActionController::Cookies

    def index
        #rp = Report.find(10)
        #UserMailer.followUpUser(rp.r_email, rp).deliver_later if rp.r_email
        #UserMailer.newReportAdmin(rp).deliver_later
    end
	def sendToken
        email = params[:email]
        user = User.find_by(email: email)
        if user
            rand_token = 6.times.map{rand(10)}.join
            user.token = rand_token
            user.token_last_update = DateTime.now
            user.save
            UserMailer.email_token(user, rand_token,params[:lang]).deliver_later ##SEND EMAIL
            render :json => { :error => false, :msg => "Email sended" }
        else
            render :json => { :error => true, :msg => "Email not found" }
        end
    end

	def loginToken
        email = params[:email]
        token = params[:token]
        user = User.where(email: email, token: token).take
        if user
            token = encode_token(user, token)
            render :json => { :error => false, :token => token }
        else
            render :json => { :error => true, :msg => "invalid User" }
        end
    end

    def getGoogleRoute
        scope = [
            "https://www.googleapis.com/auth/userinfo.profile",
            "https://www.googleapis.com/auth/userinfo.email"
        ].join(" ")
        data = [ Rails.application.credentials.google[:gp_client_id], scope, url_google ]
        url = "https://accounts.google.com/o/oauth2/auth?client_id=%s&response_type=code&scope=%s&redirect_uri=%s&state=google" % data
        redirect_to url
    end
    def googleLogin
       
        prms = {
            'grant_type': 'authorization_code',
            'code': params[:code],
            'redirect_uri': url_google,
            'client_id': Rails.application.credentials.google[:gp_client_id],
            'client_secret': Rails.application.credentials.google[:gp_client_secret]
        }
        url = URI('https://accounts.google.com/o/oauth2/token')
        response = Net::HTTP.post_form(url, prms)
        if response.is_a?(Net::HTTPSuccess)
            body = response.body
            url = URI('https://www.googleapis.com/oauth2/v1/userinfo')
            access_token = JSON.parse(body)["access_token"]
            url.query = URI.encode_www_form({'access_token': access_token})
            response = Net::HTTP.get_response(url)
           
            if response.is_a?(Net::HTTPSuccess)
               
                body = response.body
                user_data = JSON.parse(body)
                email = user_data["email"]
                if email
                    user = User.find_by(email: email)
                    if user
                        token = 6.times.map{rand(10)}.join
                        token = encode_token(user, token)
                        cookies[:hotline] = {
                            :value => token,
                            :domain => URL_FRONT,
                            :expires => 1.day.from_now
                        }
                        #redirect_to("#{URL_FRONT}/admin/admin-home") #logintoken
                    else
                        redirect_to("#{URL_FRONT}/admin/UserNot") #User not found
                    end
                else
                    
                    redirect_to("#{URL_FRONT}/admin/UserNot") #Email gmail error
                end
            end
        end
    end
    def loginReport
        report = Report.find_by(r_reference: params[:reference])
        isAuthed = report.try(:authenticate, params[:password])
        if !report
            render json: {
                key: 'username',
                message: 'No Report can be found'
            }, status: :forbidden
        elsif !isAuthed
            render json: {
                key: 'password',
                message: 'Incorrect Password'
                }, status: :forbidden
        else
            token = encode_token_report(report)
            render json: {
                token: token,
                report_id: report.id
            }
        end
    end
    
    private
    def url_google
        url_google = request.protocol + request.host_with_port
        p '----------------------'
        p url_google
        url_google = URL_BACK
    end
    def encode_token(user, token)
        user.update(token: token, token_last_update: DateTime.now)
        payload = { id: user.id, email: user.email, token: token}
        JWT.encode(payload, Rails.application.credentials.secret_key_base, 'HS256')
    end
    def encode_token_report(report)
        report.update(token_last_update: DateTime.now)
        payload = { id: report.id, reference: report.r_reference}
        JWT.encode(payload, Rails.application.credentials.secret_key_base, 'HS256')
    end
end
