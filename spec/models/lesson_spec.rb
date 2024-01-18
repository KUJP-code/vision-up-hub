# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Lesson do
  it 'has a valid factory' do
    expect(build(:lesson)).to be_valid
  end

  it 'rejects days less than 1' do
    expect(build(:lesson, day: 0)).not_to be_valid
  end

  it 'rejects days greater than 7' do
    expect(build(:lesson, day: 8)).not_to be_valid
  end

  it 'rejects weeks less than 1' do
    expect(build(:lesson, week: 0)).not_to be_valid
  end

  it 'rejects weeks greater than 52' do
    expect(build(:lesson, week: 53)).not_to be_valid
  end
end
