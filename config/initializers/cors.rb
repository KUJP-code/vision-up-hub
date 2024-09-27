# frozen_string_literal: true

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins 'https://mike.vision-up.biz', 'https://vision-up.biz'
    resource '/inquiries', headers: :any, methods: %i[post]
  end
end
