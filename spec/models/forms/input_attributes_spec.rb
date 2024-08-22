# frozen_string_literal: true

require 'rails_helper'

RSpec.describe InputAttributes do
  it 'has a valid factory' do
    expect(build(:input_attributes)).to be_valid
  end
end
