# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User do
  it 'has a valid factory' do
    expect(build(:user)).to be_valid
  end

  context 'when checking for role' do
    it 'matches if user role matches a single string role' do
      admin = build(:user, :admin)
      expect(admin.is?('Admin')).to be true
    end

    it 'does not match if user role does not match single string role' do
      admin = build(:user, :admin)
      expect(admin.is?('Writer')).to be false
    end

    it 'matches matches any of an array of string roles' do
      writer = build(:user, :writer)
      expect(writer.is?('Admin', 'Writer')).to be true
    end

    it 'does not match if user role does not match any of an array of string roles' do
      writer = build(:user, :writer)
      expect(writer.is?('Admin', 'Teacher')).to be false
    end
  end

  context 'when working with extra emails' do
    let(:user) { build(:user, :parent, extra_emails: 'a@b.com') }

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
