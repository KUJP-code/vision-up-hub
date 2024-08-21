# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FieldAttributes do
  it 'has a valid factory' do
    expect(build(:field_attributes)).to be_valid
  end
end
