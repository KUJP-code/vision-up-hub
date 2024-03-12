# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TestResult do
  it 'has a valid factory' do
    expect(build(:test_result)).to be_valid
  end
end
