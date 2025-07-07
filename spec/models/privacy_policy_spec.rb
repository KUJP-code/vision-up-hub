# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PrivacyPolicy do
  it 'has a valid factory' do
    expect(build(:privacy_policy)).to be_valid
  end

  it 'requires a version' do
    policy = build(:privacy_policy, version: nil)
    policy.valid?
    expect(policy.errors[:version]).to include(I18n.t('errors.messages.blank'))
  end

  it 'enforces version uniqueness' do
    create(:privacy_policy, version: 'v1.0')
    dup = build(:privacy_policy, version: 'v1.0')
    dup.valid?
    expect(dup.errors[:version]).to include(I18n.t('errors.messages.taken'))
  end

  describe '.latest_id' do
    before { Rails.cache.clear }

    it 'returns the id of the most recently created policy' do
      old    = create(:privacy_policy, created_at: 2.days.ago)
      recent = create(:privacy_policy, created_at: 1.minute.ago)

      expect(described_class.latest_id).to eq(recent.id)
    end

    it 'busts the cache when a new policy is created' do
      described_class.latest_id

      expect(Rails.cache).to receive(:delete).with('latest_privacy_policy_id')
      create(:privacy_policy)
    end
  end

  it 'destroys dependent acceptances' do
    policy = create(:privacy_policy)
    create(:privacy_policy_acceptance, privacy_policy: policy)

    expect { policy.destroy }.to change(PrivacyPolicyAcceptance, :count).by(-1)
  end
end
