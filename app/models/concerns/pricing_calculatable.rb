module PricingCalculatable
  extend ActiveSupport::Concern

  included do
    COST_PER_KID = 3500
  end

  def calculate_cost_per_kid
    COST_PER_KID
  end
end
