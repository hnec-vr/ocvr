OCVR::Application.routes.draw do
  resources :signups
  resources :user_sessions

  resource :registration do
    post :findnid
    get :confirmnid
    post :rejectnid
    get :wrongnid
    post :setnid
    get :end
  end

  resource :account

  get "/login" => "user_sessions#new"

  match "/verify/:token" => "email_verifications#verify", :as => :verify_email

  get "/nonid" => "static_pages#nonid"
  get "/faq"   => "static_pages#faq"
  get "/start" => "static_pages#start"
  get "/confirm" => "static_pages#confirm"
  get '/suspended' => "static_pages#suspended"

  root :to => "home#index"
end
