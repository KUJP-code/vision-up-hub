# frozen_string_literal: true

class Invoice < ApplicationRecord
  include PricingCalculatable
  belongs_to :organisation
  validates :total_cost, :tax, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :number_of_kids, presence: true,
                             numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  before_save :calculate_costs

  private

  # calculate totals before saving the invoice
  def calculate_costs
    self.subtotal = number_of_kids * calculate_cost_per_kid
    self.tax = (subtotal * 0.10).to_i # assuming the tax rate is 10%
    self.total_cost = subtotal + tax
  end
end
