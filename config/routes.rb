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
			post :newProject
			post :DeleteReply
			get :getUser
			post :addReportReply
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
			post :deleteReply
		end
	end
end
