# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FormSubmission do
  it 'has a valid factory' do
    expect(build(:form_submission)).to be_valid
  end
end
