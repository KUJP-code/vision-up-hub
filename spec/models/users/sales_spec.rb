# frozen_string_literal: true

RSpec.describe Sales do
  it 'has a valid factory' do
    expect(build(:user, :sales)).to be_valid
  end
end
