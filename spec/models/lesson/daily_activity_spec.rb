# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Lesson::DailyActivity do
  it 'has a valid factory' do
    expect(build(:lesson, :daily_activity)).to be_valid
  end
end
