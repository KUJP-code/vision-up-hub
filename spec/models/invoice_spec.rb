# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Invoice do
  before do
    I18n.locale = :en
  end

  it 'has a valid factory' do
    expect(build(:invoice)).to be_valid
  end

  context 'when validating' do
    it 'requires number_of_kids to be present' do
      invoice = build(:invoice, number_of_kids: nil)
      invoice.valid?
      expect(invoice.errors[:number_of_kids]).to include("can't be blank")
    end

    it 'requires payment_option to be present' do
      invoice = build(:invoice, payment_option: nil)
      invoice.valid?
      expect(invoice.errors[:payment_option]).to include("can't be blank")
    end

    it 'requires payment_option to be valid' do
      invoice = build(:invoice, payment_option: 'invalid_option')
      invoice.valid?
      expect(invoice.errors[:payment_option]).to include('is not included in the list')
    end
  end

  context 'when calculating costs' do
    it 'calculates subtotal, tax, and total cost correctly' do
      invoice = build(:invoice, number_of_kids: 5, payment_option: 'default')
      invoice.save
      expect(invoice.subtotal).to eq(5 * 3500)
      expect(invoice.tax).to eq((invoice.subtotal * 0.10).to_i)
      expect(invoice.total_cost).to eq(invoice.subtotal + invoice.tax)
    end
  end
end
