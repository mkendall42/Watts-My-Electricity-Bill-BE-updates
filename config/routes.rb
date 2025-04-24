Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"

  namespace :api do
    namespace :v1 do
      resources :utilities, only: :index
      resources :users, only: [:index, :show] do
        #NOTE: will need other routes here (more for reports and users, and maybe more for utiltiies)
        resources :reports, only: [:index]  
      end
  
      resources :reports, only: [:create, :show] do
        collection do
          get :energy_usage
        end
      end
    end
  end
end
