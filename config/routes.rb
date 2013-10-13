OCVR::Application.routes.draw do
  resources :signups
  get "/login" => "user_sessions#new"

  match "/verify/:token" => "email_verifications#verify", :as => :verify_email

  get "/nonid" => "static_pages#nonid"
  get "/faq"   => "static_pages#faq"
  get "/start" => "static_pages#start"
  get "/confirm" => "static_pages#confirm"

  root :to => "home#index"
end
