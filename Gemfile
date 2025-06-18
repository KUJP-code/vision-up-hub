# frozen_string_literal: true

source 'https://rubygems.org'

ruby '3.3.1'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails', branch: "main"
gem 'rails', '7.1.3.4'

# The modern asset pipeline for Rails [https://github.com/rails/propshaft]
gem 'propshaft', '~> 0.9'

# Use postgresql as the database for Active Record
gem 'pg', '1.5.5'

# Use the Puma web server [https://github.com/puma/puma]
gem 'puma', '6.4.3'

# Bundle and transpile JavaScript [https://github.com/rails/jsbundling-rails]
gem 'jsbundling-rails', '1.3.0'

# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem 'turbo-rails', '2.0.5'

# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem 'stimulus-rails', '1.3.3'

# Bundle and process CSS [https://github.com/rails/cssbundling-rails]
gem 'cssbundling-rails', '1.4.0'

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', '1.2024.1', platforms: %i[mswin mswin64 mingw x64_mingw jruby]

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '1.18.3', require: false

# Use Devise for authentication
gem 'devise', '4.9.3'
gem 'devise-i18n', '1.12.0'


# And Pundit for authorization
gem 'pundit', '2.3.1'

# Grover for rendering HTML to PDF
gem 'grover', '~>1.0'

# Template views in HAML
gem 'haml-rails', '2.1.0'

# Use prawn to generate PDFs
gem 'prawn', '2.4.0'
gem 'prawn-table'

# Generate PDF previews
gem 'image_processing', '1.12.2'
gem 'poppler', '4.2.9'
gem 'ruby-vips', '2.2.0'

# SolidQueue for background processing
gem 'solid_queue', '1.0'

# And mission control to manage SQ jobs
gem 'mission_control-jobs', '~> 0.3'

# PgHero for DB statsp
gem 'pghero', '3.4.1'

# Integration with AWS S3
gem 'aws-sdk-s3', '1.143.0', require: false

# Lock rack to avoid vulnerabilities
gem 'rack', '3.0.9.1'

# Lock webrick version CVE-2024-27420
gem 'webrick', '1.8.2'

# Automatically set lang from user's preferred language
gem 'http_accept_language', '2.1.1'

# Lock rdoc version for CVE-2024-27281
gem 'rdoc', '6.6.3.1'

# Lock nokogiri for CVE-2024-34459
gem 'nokogiri', '1.16.5'

# Bump rexml for CVE-2024-41123
gem 'rexml', '~> 3.3.6'

# logidze for versioning
gem 'logidze', '~> 1.1'

# postgres-copy for csv export & csv cos it's not stdlib > 3.4
gem 'csv', '~> 3.3'
gem 'postgres-copy', '~> 1.7'

# Use Flipper for feature flags
gem 'flipper', '1.3.1'
gem 'flipper-active_record', '1.3.1'
gem 'flipper-ui', '1.3.1'

# lock fugit for CVE-2024-43380
gem 'fugit', '~> 1.11.1'

# Use store_model to reduce boilerplate for jsonb col models
gem 'store_model', '~> 3.0'

# Allow form submissions from .biz site
gem 'rack-cors'

# Add SVG helpers
gem 'inline_svg'

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem 'debug', platforms: %i[mri mswin mswin64 mingw x64_mingw]

  # RSpec for testing
  gem 'rspec-rails'
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem 'web-console'

  # Linting
  gem 'haml_lint', '~> 0.58', require: false
  gem 'rubocop', require: false
  gem 'rubocop-performance', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-rspec', require: false

  # Check for N+1 queries
  gem 'bullet'

  # Static analysis with brakeman
  gem 'brakeman'

  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem 'spring'
end

group :test do
  # Capybara for system testing
  gem 'capybara'
  gem 'capybara-screenshot'
  gem 'selenium-webdriver'

  # FactoryBot for test data
  gem 'factory_bot_rails'

  # DB cleaner for DB cleaning between test runs
  gem 'database_cleaner-active_record'

  # Pundit matchers for authorization testing
  gem 'pundit-matchers'

  # pdf-inspector for PDF testing
  gem 'pdf-inspector', require: 'pdf/inspector'
end
