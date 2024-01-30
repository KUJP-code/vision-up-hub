# frozen_string_literal: true

RSpec.describe Sales do
  it 'has a valid factory' do
    expect(build(:user, :sales)).to be_valid
  end

  it 'can be created at KU' do
    user = build(:user, :sales)
    user.organisation = build(:organisation, name: 'KidsUP')
    expect(user).to be_valid
  end

  it 'cannot be created at orgs other than KU' do
    user = build(:user, :sales)
    user.organisation = build(:organisation, name: 'Not KU')
    expect(user).not_to be_valid
  end
end
