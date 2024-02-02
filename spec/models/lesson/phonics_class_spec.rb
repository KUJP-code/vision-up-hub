# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PhonicsClass do
  it 'has a valid factory' do
    expect(build(:english_class)).to be_valid
  end
end
