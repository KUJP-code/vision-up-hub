# frozen_string_literal: true

module PricingCalculatable
  extend ActiveSupport::Concern

  COST_PER_KID_DEFAULT = 3500
  PAYMENT_OPTIONS = {
    default: COST_PER_KID_DEFAULT,
    premium: 4500,
    discounted: 3000
  }.freeze

  def calculate_cost_per_kid(payment_option = :default)
    PAYMENT_OPTIONS.fetch(payment_option, COST_PER_KID_DEFAULT)
  end
end
