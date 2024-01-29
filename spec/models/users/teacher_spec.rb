# frozen_string_literal: true

RSpec.describe Teacher do
  it 'has a valid factory' do
    expect(build(:user, :teacher)).to be_valid
  end
end
