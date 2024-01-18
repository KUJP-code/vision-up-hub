# frozen_string_literal: true

Rails.application.routes.draw do
  resources :courses, except: %i[destroy]
  resources :files, only: %i[create index show]
  resources :lessons, except: %i[destroy]
  devise_for :users

  # Health check endpoint
  get 'up' => 'rails/health#show', as: :rails_health_check

  root 'courses#index'
end
