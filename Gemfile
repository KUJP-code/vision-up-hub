# frozen_string_literal: true

source 'https://rubygems.org'

ruby '3.2.2'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails', branch: "main"
gem 'rails', '~> 7.1.3'

# The modern asset pipeline for Rails [https://github.com/rails/propshaft]
gem 'propshaft'

# Use postgresql as the database for Active Record
gem 'pg', '~> 1.1'

# Use the Puma web server [https://github.com/puma/puma]
gem 'puma', '~> 6.4'

# Bundle and transpile JavaScript [https://github.com/rails/jsbundling-rails]
gem 'jsbundling-rails'

# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem 'turbo-rails'

# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem 'stimulus-rails'

# Bundle and process CSS [https://github.com/rails/cssbundling-rails]
gem 'cssbundling-rails'

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mswin mswin64 mingw x64_mingw jruby]

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', require: false

# Use Devise for authentication
gem 'devise'
gem 'devise-i18n', '~> 1.12'

# And Pundit for authorization
gem 'pundit'

# Template views in HAML
gem 'haml-rails', '~> 2.1'

# Use prawn to generate PDFs
gem 'prawn', '~> 2.4'

# Generate PDF previews
gem 'image_processing', '~> 1.2'
gem 'poppler'
gem 'ruby-vips'

# SolidQueue for background processing
gem 'solid_queue'

group :production, :development do
  # Add speed badges [https://github.com/MiniProfiler/rack-mini-profiler]
  gem 'rack-mini-profiler'
end

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem 'debug', platforms: %i[mri mswin mswin64 mingw x64_mingw]
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem 'web-console'

  # Use rubocop
  gem 'rubocop', require: false
  gem 'rubocop-performance', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-rspec', require: false

  # Check for N+1 queries
  gem 'bullet'

  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem 'spring'
end

group :test do
  # RSpec for testing
  gem 'rspec-rails'

  # Capybara for system testing
  gem 'capybara'
  gem 'capybara-screenshot'

  # FactoryBot for test data
  gem 'factory_bot_rails'

  # DB cleaner for DB cleaning between test runs
  gem 'database_cleaner-active_record'

  # Pundit matchers for authorization testing
  gem 'pundit-matchers'

  # pdf-inspector for PDF testing
  gem 'pdf-inspector', require: 'pdf/inspector'
end
