# frozen_string_literal: true

Rspec.configure do |config|
  config.before(:each, type: :system) do
    driven_by :rack_test
  end
end

require 'capybara-screenshot/rspec'
