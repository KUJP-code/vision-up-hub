# frozen_string_literal: true

require 'active_support/core_ext/integer/time'

Rails.application.configure do
  config.allow_concurrency = true   # let Puma serve a second request
  config.after_initialize do
    Bullet.enable        = true
    Bullet.rails_logger  = true
    Bullet.add_footer    = true
  end

  # In the development environment your application's code is reloaded any time
  # it changes. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.enable_reloading = true

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports.
  config.consider_all_requests_local = true

  # Enable server timing
  config.server_timing = true

  # Enable/disable caching. By default caching is disabled.
  # Run rails dev:cache to toggle caching.
  if Rails.root.join('tmp/caching-dev.txt').exist?
    config.action_controller.perform_caching = true
    config.action_controller.enable_fragment_cache_logging = true
    config.cache_store = :memory_store
    config.public_file_server.headers = {
      'Cache-Control' => "public, max-age=#{2.days.to_i}"
    }
  else
    config.action_controller.perform_caching = false
    config.cache_store = :null_store
  end

  # Store uploaded files on the local file system (see config/storage.yml for options).
  config.active_storage.service = :local

  # Don't care if the mailer can't send & configure for Devise
  config.action_mailer.raise_delivery_errors = false
  config.action_mailer.perform_caching = false
  config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise exceptions for disallowed deprecations.
  config.active_support.disallowed_deprecation = :raise

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Highlight code that triggered database queries in logs.
  config.active_record.verbose_query_logs = true

  # Highlight code that enqueued background job in logs.
  config.active_job.verbose_enqueue_logs = true

  # Raises error for missing translations.
  config.i18n.raise_on_missing_translations = false

  # Raise error when a before_action's only/except options reference missing actions
  config.action_controller.raise_on_missing_callback_actions = true

  # Suppress logger output for asset requests.
  config.assets.quiet = true

  config.public_file_server.headers = {
    "Access-Control-Allow-Origin"   => "*",
    "Access-Control-Allow-Methods"  => "GET, OPTIONS, HEAD",
    "Access-Control-Allow-Headers"  => "Origin, Content-Type, Accept"
  }
  # Use separate queues per environment
  config.active_job.queue_name_prefix = 'materials_production'

  # ActiveRecord encryption keys
  config.active_record.encryption.primary_key = Rails.application.credentials.dig(:active_record_encryption,
                                                                                  :primary_key)
  config.active_record.encryption.deterministic_key = Rails.application.credentials.dig(:active_record_encryption,
                                                                                        :deterministic_key)
  config.active_record.encryption.key_derivation_salt = Rails.application.credentials.dig(:active_record_encryption,
                                                                                          :key_derivation_salt)
end
