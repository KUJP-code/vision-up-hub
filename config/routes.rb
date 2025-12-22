# frozen_string_literal: true

Rails.application.routes.draw do
  scope '(/:locale)', locale: /ja|en/ do
    devise_for :users
    resources :privacy_policy_acceptances, only: %i[new create index]
    get 'pending_device', to: 'devices#pending', as: :pending_device

    authenticate :user do
      resources :announcements
      resources :invoices, only: %i[index new create update destroy] do
        member do
          get :pdf, defaults: { format: :pdf }
        end
      end
      resources :category_resources, except: %i[show]
      resources :courses, except: %i[destroy] do
        resources :course_lesson_uploads, only: %i[create new show]
      end
      resources :homeworks, only: %i[index new create destroy edit update]
      resources :csv_exports, only: %i[index new show]
      resources :daily_activities, only: %i[create index update]
      resources :english_classes, only: %i[create index update]
      resources :exercises, only: %i[create index update]
      resources :evening_classes, only: %i[create index update]
      resources :files, only: %i[destroy index show]
      resources :homework_resources, only: %i[destroy index]
      resources :kindy_phonics, only: %i[create index update]
      resources :lessons
      resources :lesson_calendars, only: %i[index]
      resources :lesson_searches, only: %i[index]
      resources :lesson_uses, only: %i[index]
      resources :lesson_versions, only: %i[show update]
      resources :level_changes, only: %i[new create]
      resources :missing_lessons, only: %i[index]
      resources :monthly_materials, only: %i[index]
      resources :notifications, except: %i[edit]
      resources :privacy_policies, only: %i[new create show]
      resources :parents_reports, only: %i[create index update]
      resources :proposals, only: %i[show update]
      resources :phonics_classes, only: %i[create index update]
      resources :phonics_resources, only: %i[destroy]
      resources :plans
      resources :school_classes
      resources :seasonal_activities, only: %i[create index update]
      resources :party_activities, only: %i[create index update]
      resources :event_activities, only: %i[create index update]
      resources :report_card_batches, only: %i[index create] do
        post :regenerate, on: :member
      end
      resources :special_lessons, only: %i[create index update]
      resources :stand_show_speaks, only: %i[create index update]
      resources :tutorials
      resources :tutorial_categories
      resources :user_searches, only: %i[index]
      resources :students, except: %i[destroy] do
        member do
          get :icon_chooser
          get :homework_resources
          get :print_version
          get :report_card_pdf
          get :pearson_report, defaults: { format: :pdf }
        end
      end

      resources :student_searches, only: %i[index update]
      resources :support_requests do
        resources :support_messages, only: %i[create]
      end
      resources :teacher_lessons, only: %i[index show]
      resources :teacher_events, only: %i[index show]
      resources :teacher_resources, only: %i[index]
      resources :tests, except: %i[show] do
        resources :test_results, only: %i[create index update]
      end

      resources :organisations, except: %i[destroy] do
        resources :form_submissions, shallow: true
        resources :form_templates, shallow: true
        resources :schools

        resources :student_uploads, only: %i[create new show]
        patch 'student_uploads', to: 'student_uploads#update', as: :student_uploads_update
        resources :teacher_uploads, only: %i[create new show]
        patch 'teacher_uploads', to: 'teacher_uploads#update', as: :teacher_uploads_update
        resources :parent_uploads, only: %i[create new show]
        patch 'parent_uploads', to: 'parent_uploads#update', as: :parent_uploads_update
        resources :pearson_uploads, only: %i[create new show]
        resources :users, except: %i[destroy]
        resources :admins
        resources :org_admins
        resources :parents
        resources :sales
        resources :school_managers
        resources :teachers
        resources :writers
      end
      post 'reassign_editor', to: 'admins#reassign_editor', as: :reassign_editor
      get 'admin_password_change', to: 'admins#new_password_change', as: :admin_password_change
      post 'admin_password_change', to: 'admins#change_password', as: :admin_change_password
      get 'teacher_homework', to: 'homeworks#teacher_index', as: :teacher_homework

      # Index for KU staff who can see everything
      get 'users', to: 'users#index', as: :users
    end

    authenticate :user, ->(user) { user.is?('Admin') } do
      mount Flipper::UI.app(Flipper) => '/flipper', as: :flipper
      mount MissionControl::Jobs::Engine, at: '/jobs'
      mount PgHero::Engine, at: '/pghero'
      resources :devices, only: [:index, :update, :destroy]
      resources :triggerable_jobs, only: %i[index create]
    end

    authenticated :user do
      root to: 'users#show', as: :authenticated_root
    end

    root to: 'splashes#welcome'
  end

  # Receives inquiries from contact form & forwards to Nakagawa
  post 'inquiries' => 'inquiries#create'

  # Health check endpoint
  get 'up' => 'rails/health#show', as: :rails_health_check
end
