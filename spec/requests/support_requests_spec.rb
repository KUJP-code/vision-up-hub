# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SupportRequest do
  let(:user) { create(:user, :teacher) }
  let(:support_request) { create(:support_request, seen_by: [], user:) }

  before do
    sign_in user
  end

  after do
    sign_out user
  end

  it 'marks seen when show visited' do
    get support_request_path(support_request)
    expect(support_request.reload.seen_by?(user.id)).to be true
  end

  it 'marks all unseen when updated' do
    support_request.mark_seen_by(user.id)
    support_request.mark_seen_by(9_999_999)
    patch support_request_path(support_request),
          params: { support_request: { subject: 'New Subject' } }
    expect(support_request.reload.seen_by).to eq([])
  end
end
