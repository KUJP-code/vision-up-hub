# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Student do
  it 'has a valid factory' do
    expect(build(:student)).to be_valid
  end
end
