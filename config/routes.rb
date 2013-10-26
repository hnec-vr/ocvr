OCVR::Application.routes.draw do
  namespace :admin do
    resources :nid_reviews do
      post :approve, :on => :member
      post :deny,    :on => :member
      post :reverse_approval, :on => :member
    end

    resources :users do
      post :activate,   :on => :member
      post :deactivate, :on => :member
    end

    root :to => "nid_reviews#index"
  end

  resources :signups
  resources :user_sessions

  resources :password_resets do
    get :sent, :on => :collection
  end

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
    get :print
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
  get '/closed'    => "static_pages#closed"

  root :to => "home#index"
end
