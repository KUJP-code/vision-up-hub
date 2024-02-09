# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PhonicsClass do
  it 'has a valid factory' do
    expect(build(:phonics_class)).to be_valid
  end

  it_behaves_like 'lesson'
end
