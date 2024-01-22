# frozen_string_literal: true

Rails.application.routes.draw do
  resources :organisations, except: %i[destroy] do
    resources :users
  end
  resources :courses, except: %i[destroy] do
    resources :lessons, except: %i[destroy]
    resources :daily_activities, only: %i[create]
    resources :exercises, only: %i[create]
  end
  resources :files, only: %i[create index show]
  devise_for :users

  # Health check endpoint
  get 'up' => 'rails/health#show', as: :rails_health_check

  root 'courses#index'
end
