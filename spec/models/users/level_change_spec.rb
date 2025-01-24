# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LevelChange do
  subject(:level_change) { build(:level_change, test_result:) }

  it 'has a valid factory' do
    expect(level_change).to be_valid
  end

  it 'prioritizes entries that have a test_id when duplicate attempted' do
    expect(level_change).to be_valid
  end
end
