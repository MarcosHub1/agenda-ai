Rails.application.routes.draw do
  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  get "up" => "rails/health#show", as: :rails_health_check

  # Auth
  resource :session, only: %i[new create destroy]
  resources :passwords, param: :token

  # Dashboard (autenticado, tenant-scoped)
  namespace :dashboard do
    root to: "home#index"

    resources :appointments do
      member do
        patch :confirm
        patch :cancel
        patch :complete
        patch :no_show
      end
    end

    resources :professionals do
      resources :work_schedules, only: %i[index update]
      resources :schedule_exceptions, only: %i[index create destroy]
    end

    resources :services
    resources :clients, only: %i[index show]
    resource :settings, only: %i[show edit update]
    resource :billing, only: %i[show], controller: "billing" do
      post :checkout
      match :portal, via: %i[get post]
      get :success
      get :cancel
    end
  end

  # Webhooks Stripe
  post "/webhooks/stripe", to: "webhooks/stripe#create"

  # Booking Page pública (/:tenant_slug e /b/:tenant_slug)
  scope "(:prefix)", prefix: /b/, as: :booking_prefix do
    scope "/:tenant_slug", as: :booking do
      get "/", to: "booking/services#index"
      get "/professionals", to: "booking/professionals#index", as: :professionals
      get "/slots", to: "booking/slots#index", as: :slots
      resources :appointments, only: %i[new create show],
                               controller: "booking/appointments",
                               as: :appointments
    end
  end

  # Root route
  root to: "dashboard/home#index"
end
