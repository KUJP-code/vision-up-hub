# frozen_string_literal: true

class Invoice < ApplicationRecord
  include PricingCalculatable
  belongs_to :organisation
  before_validation :set_number_of_kids, if: -> { organisation_id.present? && number_of_kids.blank? }
  before_validation :calculate_costs
  validates :total_cost, :tax, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :number_of_kids, presence: true,
                             numericality: { greater_than_or_equal_to: 0 }
  validates :payment_option, presence: true, inclusion: { in: PricingCalculatable::PAYMENT_OPTIONS.keys.map(&:to_s) }

  private

  def set_number_of_kids
    self.number_of_kids = organisation.students_count
    Rails.logger.info "Setting number_of_kids: #{number_of_kids} for organisation_id: #{organisation_id}"
  end

  # calculate totals before saving the invoice
  def calculate_costs
    self.subtotal = number_of_kids * calculate_cost_per_kid
    self.tax = (subtotal * 0.10).to_i # assuming the tax rate is 10%
    self.total_cost = subtotal + tax
    Rails.logger.info "Calculated costs: subtotal=#{subtotal}, tax=#{tax}, total_cost=#{total_cost}"
  end
end
