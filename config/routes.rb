Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
	begin 
		namespace :web_report do
			post :submitAnswer
			post :createPassword
		end
		namespace :admin do
			get :listReports
			get :getProjects
			get :getProjectDetail
			post :newProject
		end
		namespace :login do
			post :sendToken
			post :loginToken
			get :getGoogleRoute
			get :googleLogin
		end
	end
end
