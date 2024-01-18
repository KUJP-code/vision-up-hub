# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User do
  it 'has a valid factory' do
    expect(build(:user)).to be_valid
  end

  it 'is a teacher by default' do
    expect(build(:user)).to be_teacher
  end
end
