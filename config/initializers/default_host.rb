Rails.application.routes.default_url_options[:host] =
  ENV.fetch('APP_HOST', 'https://hub.kids-up.app')