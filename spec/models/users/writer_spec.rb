# frozen_string_literal: true

RSpec.describe Writer do
  it 'has a valid factory' do
    expect(build(:user, :writer)).to be_valid
  end
end
