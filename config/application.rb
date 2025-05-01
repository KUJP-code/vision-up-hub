require_relative 'boot'

require 'rails'
# Pick the frameworks you want:
require 'active_model/railtie'
require 'active_job/railtie'
require 'active_record/railtie'
require 'active_storage/engine'
require 'action_controller/railtie'
require 'action_mailer/railtie'
# require "action_mailbox/engine"
# require "action_text/engine"
require 'action_view/railtie'
# FIXME: Temporarily needed til turbo-rails > 2.0.2
# fixes https://github.com/hotwired/turbo-rails/issues/512
require 'action_cable/engine'
# require "rails/test_unit/railtie"

Bundler.require(*Rails.groups)

module Materials
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.1

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    config.autoload_paths += Dir[Rails.root.join('app/assets/**/')]
    # Allow nesting models and controllers in subfolders
    config.autoload_paths += Dir[Rails.root.join('app/controllers/**/')]
    config.autoload_paths += Dir[Rails.root.join('app/models/**/')]
    config.autoload_paths += Dir[Rails.root.join('app/policies/**/')]
    # Add path for custom types
    config.autoload_paths += Dir[Rails.root.join('app/types/**/')]

    # Don't generate system test files.
    config.generators.system_tests = nil

    # Locale settings
    config.i18n.load_path += Dir[Rails.root.join('config/locales/**/*.yml')]
    config.time_zone = 'Tokyo'
    config.active_record.default_timezone = :local

    # Use SolidQueue for ActiveJob
    config.active_job.queue_adapter = :solid_queue

    # Lazyload images by default
    config.action_view.image_loading = 'lazy'

    # logidze needs the schema to be in SQL format
    config.active_record.schema_format = :sql

  end
end
