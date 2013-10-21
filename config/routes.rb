OCVR::Application.routes.draw do
  namespace :admin do
    resources :nid_reviews do
      post :approve, :on => :member
      post :deny,    :on => :member
    end

    root :to => "nid_reviews#index"
  end

  resources :signups
  resources :user_sessions

  resource :registration do
    post :findnid
    get :confirmnid
    post :rejectnid
    get :wrongnid
    post :setnid
    get :reclaimnid
    post :matchnid
    get :nidreview
    get :end
  end

  resource :account

  get "/login" => "user_sessions#new"
  delete "/logout" => "user_sessions#destroy"

  match "/verify/:token" => "email_verifications#verify", :as => :verify_email

  get "/nonid" => "static_pages#nonid"
  get "/faq"   => "static_pages#faq"
  get "/start" => "static_pages#start"
  get "/confirm" => "static_pages#confirm"
  get '/suspended' => "static_pages#suspended"

  root :to => "home#index"
end
