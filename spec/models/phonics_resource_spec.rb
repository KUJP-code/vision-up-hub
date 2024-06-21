# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PhonicsResource do
  it 'has a valid factory' do
    expect(build(:phonics_resource)).to be_valid
  end
end
