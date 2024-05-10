# frozen_string_literal: true

Rails.application.routes.draw do
  scope '(/:locale)', locale: /ja|en/ do
    devise_for :users

    authenticate :user do
      resources :courses, except: %i[destroy]
      resources :daily_activities, only: %i[create index update]
      resources :english_classes, only: %i[create index update]
      resources :exercises, only: %i[create index update]
      resources :files, only: %i[show]
      resources :lessons
      resources :lesson_searches, only: %i[index]
      resources :proposals, only: %i[show update]
      resources :phonics_classes, only: %i[create index update]
      resources :plans
      resources :school_classes
      resources :stand_show_speaks, only: %i[create index update]
      resources :students
      resources :student_searches, only: %i[index update]
      resources :support_requests do
        resources :support_messages, only: %i[create]
      end
      resources :tests do
        resources :test_results, only: %i[create index update]
      end

      resources :organisations, except: %i[destroy] do
        resources :schools
        resources :student_uploads, only: %i[create new]
        patch 'student_uploads', to: 'student_uploads#update'

        resources :users, except: %i[destroy]
        resources :admins, except: %i[destroy]
        resources :org_admins
        resources :parents
        resources :sales
        resources :school_managers
        resources :teachers
        resources :writers
      end
      post 'reassign_editor', to: 'admins#reassign_editor', as: :reassign_editor

      # Index for KU staff who can see everything
      get 'users', to: 'users#index', as: :users
      resources :user_searches, only: %i[index]
    end

    authenticate :user, ->(user) { user.is?('Admin') } do
      mount PgHero::Engine, at: '/pghero'
      mount MissionControl::Jobs::Engine, at: '/jobs'
    end

    authenticated :user do
      root to: 'users#show', as: :authenticated_root
    end

    root to: 'splashes#welcome'
  end

  # Health check endpoint
  get 'up' => 'rails/health#show', as: :rails_health_check
end
