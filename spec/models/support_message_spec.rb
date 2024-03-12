# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SupportMessage do
  it 'has a valid factory' do
    support_message = build(:support_message)
    expect(support_message).to be_valid
  end
end
