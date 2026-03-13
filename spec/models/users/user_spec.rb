# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User do
  it 'has a valid factory' do
    expect(build(:user)).to be_valid
  end

  describe 'password complexity' do
    it 'requires uppercase, lowercase, and a number' do
      user = build(:user, password: 'lowercase123', password_confirmation: 'lowercase123')

      expect(user).not_to be_valid
      expect(user.errors[:password]).to include(
        'must include at least one uppercase letter, one lowercase letter, and one number'
      )
    end

    it 'accepts a password with uppercase, lowercase, and a number' do
      user = build(:user, password: 'Password123', password_confirmation: 'Password123')

      expect(user).to be_valid
    end
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

  context 'when working with notifications' do
    # let(:user) { build(:user) }
    # let(:notification) { build(:notification) }
    #
    # it 'can add notifications' do
    #   user.add_notification
    #   expect(user.notifications.count).to eq(1)
    # end
  end
end
