# frozen_string_literal: true

RSpec.describe LevelChange do
  subject(:level_change) { build(:level_change, test_result, new_level: 'sky_three') }

  it 'has a valid factory' do
    expect(level_change).to be_valid
  end
end
