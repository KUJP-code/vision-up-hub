# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SessionHandoff do
  include ActiveSupport::Testing::TimeHelpers

  let(:user) { create(:user, :admin) }
  let(:host) { 'hub.kids-up.app' }
  let(:state) { SecureRandom.urlsafe_base64(32) }
  let(:token) { described_class.issue(user:, host:, state:) }

  it 'redeems a grant once and stores only token digests' do
    expect(described_class.redeem(token:, host:, state:)).to eq(user)
    expect(described_class.redeem(token:, host:, state:)).to be_nil

    fresh_token = described_class.issue(user:, host:, state:)
    expect(described_class.last.token_digest).not_to eq(fresh_token)
    expect(described_class.last.state_digest).not_to eq(state)
  end

  it 'rejects an expired grant' do
    issued_token = token
    travel 61.seconds do
      expect(described_class.redeem(token: issued_token, host:, state:)).to be_nil
    end
  end

  it 'rejects a grant for a different host or browser state' do
    expect(described_class.redeem(token:, host: 'vision-up.app', state:)).to be_nil
    expect(described_class.redeem(token:, host:, state: 'other-browser')).to be_nil
    expect(described_class.redeem(token:, host:, state:)).to eq(user)
  end

  it 'rejects a grant after the account is locked' do
    issued_token = token
    user.update!(locked_at: Time.current)
    expect(described_class.redeem(token: issued_token, host:, state:)).to be_nil
  end

  it 'rejects a grant after the password changes' do
    issued_token = token
    user.update!(password: 'DifferentPassword123')
    expect(described_class.redeem(token: issued_token, host:, state:)).to be_nil
  end

  it 'cleans up expired grants when issuing another' do
    token
    described_class.last.update!(expires_at: 1.minute.ago)
    expect { described_class.issue(user:, host:, state:) }.not_to change(described_class, :count)
  end
end
