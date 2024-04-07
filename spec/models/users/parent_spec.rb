# frozen_string_literal: true

RSpec.describe Parent do
  it 'has a valid factory' do
    expect(build(:user, :parent)).to be_valid
  end
end
