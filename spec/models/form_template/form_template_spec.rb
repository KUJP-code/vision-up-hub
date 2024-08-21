# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FormTemplate do
  it 'has a valid factory' do
    expect(build(:form_template)).to be_valid
  end
end
