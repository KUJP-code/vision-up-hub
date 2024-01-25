# frozen_string_literal: true

Rails.application.routes.draw do
  resources :organisations, except: %i[destroy] do
    resources :users
  end
  resources :courses, except: %i[destroy]

  resources :lessons, except: %i[destroy]
  resources :daily_activities, only: %i[create update]
  resources :exercises, only: %i[create update]

  resources :files, only: %i[create index show]
  devise_for :users

  # Health check endpoint
  get 'up' => 'rails/health#show', as: :rails_health_check

  root 'courses#index'
end
