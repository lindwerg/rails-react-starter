Rails.application.routes.draw do
  # Health check (Kamal & uptime monitors)
  get "up" => "rails/health#show", as: :rails_health_check

  # OpenAPI
  mount Rswag::Ui::Engine => "/api-docs"
  mount Rswag::Api::Engine => "/api-docs"

  # API v1
  namespace :api do
    namespace :v1 do
      # Auth
      post   "auth/sign_up", to: "auth#sign_up"
      post   "auth/sign_in", to: "auth#sign_in"
      delete "auth/sign_out", to: "auth#sign_out"

      # Current user
      get "me", to: "me#show"

      # Posts CRUD
      resources :posts
    end
  end
end
