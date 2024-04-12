# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SchoolManager do
  it 'has a valid factory' do
    expect(build(:user, :school_manager)).to be_valid
  end
end
