# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin do
  it 'can be created at KU' do
    user = create(:user, :admin, organisation: create(:organisation, name: 'KidsUP'))
    expect(user).to be_valid
  end

  it 'cannot be created at orgs other than KU' do
    user = build(:user, :admin, organisation: create(:organisation, name: 'Not KU'))
    expect { user.save! }.to raise_error ActiveRecord::RecordInvalid
  end
end
