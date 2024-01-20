# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DailyActivity do
  it 'has a valid factory' do
    expect(build(:daily_activity)).to be_valid
  end
end
