# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PrivacyPolicyAcceptance do
  it 'has a valid factory' do
    expect(build(:privacy_policy_acceptance)).to be_valid
  end

  it 'requires accepted_at' do
    acceptance = build(:privacy_policy_acceptance, accepted_at: nil)
    acceptance.valid?
    expect(acceptance.errors[:accepted_at]).to include(I18n.t('errors.messages.blank'))
  end

  it 'enforces uniqueness per user / policy' do
    existing = create(:privacy_policy_acceptance)
    dup = build(:privacy_policy_acceptance,
                user: existing.user,
                privacy_policy: existing.privacy_policy)
    dup.valid?
    expect(dup.errors[:user_id]).to include(I18n.t('errors.messages.taken'))
  end
end
