# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Parent do
  it 'has a valid factory' do
    expect(build(:user, :parent)).to be_valid
  end

  context 'when working with extra emails' do
    let(:user) { build(:user, :parent, extra_emails: 'a@b.com') }

    it 'rejects invalid email' do
      user.extra_emails = 'ab.com'
      user.valid?
      expect(user.errors[:extra_emails]).to be_present
    end

    it 'allows adding emails' do
      user.update(extra_emails: 'c@d.com')
      expect(user.extra_emails.count).to eq(2)
    end

    it 'appends the new email to the list of extra emails' do
      user.update(extra_emails: 'c@d.com')
      expect(user.extra_emails).to contain_exactly('a@b.com', 'c@d.com')
    end

    it 'does not add duplicate emails' do
      user.update(extra_emails: 'a@b.com, a@b.com')
      expect(user.extra_emails.count).to eq(1)
    end

    it 'cannot remove old emails when just updating the field' do
      user.update(extra_emails: '')
      expect(user.extra_emails.count).to eq(1)
    end

    # we want staff to be able to remove them via a separate interface
    # but not parents to avoid separated parent drama
    it 'can remove old emails when specific method called' do
      user.remove_extra_email('a@b.com')
      expect(user.reload.extra_emails.count).to eq(0)
    end
  end
end
