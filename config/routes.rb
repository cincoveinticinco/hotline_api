Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
	begin 
		namespace :web_report do
			post :submitAnswer
			post :createPassword
			get :getProjectName
		end
		namespace :admin do
			get :listReports
			get :getReportDetail
			get :getProjects
			post :addReportReply
			post :newProject
			post :DeleteReply
			get :getUser
		end
		namespace :login do
			post :sendToken
			post :loginToken
			get :getGoogleRoute
			get :googleLogin
			post :loginReport
			get :index
		end
		namespace :report do
			post :infoReport
			post :replyReport
		end
	end
end
