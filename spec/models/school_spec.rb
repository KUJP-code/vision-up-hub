# frozen_string_literal: true

require 'rails_helper'

RSpec.describe School do
  it 'has a valid factory' do
    expect(build(:school)).to be_valid
  end
end
