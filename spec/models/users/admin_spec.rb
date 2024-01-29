# frozen_string_literal: true

RSpec.describe Admin do
  it 'has a valid factory' do
    expect(build(:user, :admin)).to be_valid
  end
end
