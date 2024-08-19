# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SupportRequest do
  it 'has a valid factory' do
    expect(build(:support_request)).to be_valid
  end

  context 'when modifying seen_by' do
    it 'adds the provided user_id when mark_seen_by is called' do
      request = create(:support_request, seen_by: [1, 2, 3])
      request.mark_seen_by(4)
      expect(request.seen_by).to eq([1, 2, 3, 4])
    end

    it 'does not add provided user_id if already in seen_by' do
      request = create(:support_request, seen_by: [1, 2, 3])
      request.mark_seen_by(3)
      expect(request.seen_by).to eq([1, 2, 3])
    end

    it 'can be reset to empty array by mark_all_unseen' do
      request = create(:support_request, seen_by: [1, 2, 3])
      request.mark_all_unseen
      expect(request.seen_by).to eq([])
    end

    it 'resets to empty array when new support message added' do
      request = create(:support_request, seen_by: [1, 2, 3])
      request.messages.create(attributes_for(:support_message))
      expect(request.seen_by).to eq([])
    end
  end

  context 'when querying seen_by?' do
    it 'returns true when user is in seen_by' do
      request = create(:support_request, seen_by: [1, 2, 3])
      expect(request.seen_by?(1)).to be true
    end

    it 'returns false when user is not in seen_by' do
      request = create(:support_request, seen_by: [1, 2, 3])
      expect(request.seen_by?(4)).to be false
    end
  end

  context 'when providing lists of participants' do
    let(:request) { create(:support_request, user: create(:user, :teacher)) }

    it 'includes creator of request' do
      expect(request.participants).to include(request.user)
    end

    it 'lists all people who messaged' do
      message_senders = create_list(:user, 2)
      message_senders.each do |sender|
        create(:support_message, user: sender, support_request: request)
      end
      expect(request.participants).to match_array(message_senders + [request.user])
    end

    it 'does not duplicate creator if they also messaged' do
      request.messages.create(attributes_for(:support_message, user: request.user))
      request_user_count = request.participants.count { |u| u == request.user }
      expect(request_user_count).to be 1
    end
  end
end
