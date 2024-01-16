# frozen_string_literal: true

Rails.application.routes.draw do
  resources :courses, except: %i[destroy]
  resources :uploads
  devise_for :users

  # Health check endpoint
  get 'up' => 'rails/health#show', as: :rails_health_check

  # Defines the root path route ("/")
  root 'courses#index'
end
