# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SchoolClass do
  it 'has a valid factory' do
    expect(build(:school_class)).to be_valid
  end
end
