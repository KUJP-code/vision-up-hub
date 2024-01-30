# frozen_string_literal: true

RSpec.describe Writer do
  it 'has a valid factory' do
    expect(build(:user, :writer)).to be_valid
  end

  it 'can be created at KU' do
    user = build(:user, :writer)
    user.organisation = build(:organisation, name: 'KidsUP')
    expect(user).to be_valid
  end

  it 'cannot be created at orgs other than KU' do
    user = build(:user, :writer)
    user.organisation = build(:organisation, name: 'Not KU')
    expect(user).not_to be_valid
  end
end
