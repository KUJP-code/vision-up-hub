# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User do
  it 'has a valid factory' do
    expect(build(:user)).to be_valid
  end

  context 'when checking for role' do
    it 'matches if user role matches a single string role' do
      admin_user = build(:user, :admin)
      expect(admin_user.is?('Admin')).to be true
    end

    it 'does not match if user role does not match single string role' do
      admin_user = build(:user, :admin)
      expect(admin_user.is?('Curriculum')).to be false
    end

    it 'matches matches any of an array of string roles' do
      curriculum_user = build(:user, :curriculum)
      expect(curriculum_user.is?('Admin', 'Curriculum')).to be true
    end

    it 'does not match if user role does not match any of an array of string roles' do
      curriculum_user = build(:user, :curriculum)
      expect(curriculum_user.is?('Admin', 'Teacher')).to be false
    end
  end
end
