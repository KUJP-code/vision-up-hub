# frozen_string_literal: true

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins 'https://hub.vision-up.app'
    resource '*', headers: :any, methods: %i[get post put patch delete options head]
  end
  allow do
    origins %w[https://mike.vision-up.biz https://www.mike.vision-up.biz https://vision-up.biz https://www.vision-up.biz]
    resource '/inquiries', headers: :any, methods: %i[post]
  end
end
