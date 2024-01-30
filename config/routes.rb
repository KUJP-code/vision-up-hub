# frozen_string_literal: true

Rails.application.routes.draw do
  resources :schools
  scope '(/:locale)',
        locale: /ja|en/,
        defaults: { locale: :ja } do
    devise_for :users

    authenticate :user do
      resources :courses, except: %i[destroy]
      resources :daily_activities, only: %i[create index update]
      resources :english_classes, only: %i[create index update]
      resources :exercises, only: %i[create index update]
      resources :files, only: %i[create index show]
      resources :lessons, except: %i[destroy]
      resources :phonics, only: %i[create index update]

      resources :organisations, except: %i[destroy show] do
        resources :admins, except: %i[destroy]
        resources :org_admins
        resources :sales
        resources :school_managers
        resources :teachers
        resources :writers
      end
    end

    authenticate :user, -> (user) { user.is?('Admin') } do
      mount PgHero::Engine, at: "pghero"
    end

    authenticated :user do
      root to: 'users#show', as: :authenticated_root
    end

    root to: 'splashes#welcome'
  end

  # Health check endpoint
  get 'up' => 'rails/health#show', as: :rails_health_check
end
