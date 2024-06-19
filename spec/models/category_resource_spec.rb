# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CategoryResource do
  it 'has a valid factory' do
    expect(build(:category_resource)).to be_valid
  end
end
