class LoginController < ApplicationController
    require 'jwt'
    require 'date'
    require 'uri'
    require 'net/http'

	def sendToken
        email = params[:email]
        user = User.find_by(email: email)
        if user
            rand_token = 6.times.map{rand(10)}.join
            user.token = rand_token
            user.token_last_update = DateTime.now
            user.save
            ##SEND EMAIL
            UserMailer.email_token(user, rand_token).deliver_later   
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
        data = [ Rails.application.credentials.gp_client_id, scope, url_google ]
        url = "https://accounts.google.com/o/oauth2/auth?client_id=%s&response_type=code&scope=%s&redirect_uri=%s&state=google" % data
        redirect_to url
    end
    def googleLogin
        prms = {
            'grant_type': 'authorization_code',
            'code': params[:code],
            'redirect_uri': url_google,
            'client_id': Rails.application.credentials.gp_client_id,
            'client_secret': Rails.application.credentials.gp_client_secret
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
                        redirect_to("/#{token}") #logintoken
                    else
                        redirect_to('/') #User not found
                    end
                else
                    redirect_to('/') #Email gmail error
                end
            end
        end
    end

    private
    def url_google
        url_google = request.protocol + request.host_with_port
        url_google + '/login/googleLogin'
    end
    def encode_token(user, token)
        user.update(token: token, token_last_update: DateTime.now)
        payload = { id: user.id, email: user.email, token: token}
        JWT.encode(payload, Rails.application.credentials.secret_key_base, 'HS256')
    end
end
