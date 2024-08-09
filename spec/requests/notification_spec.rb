# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Notifications' do
  let(:user) { create(:user, :admin) }
  let(:text) { 'Test Notification' }
  let(:link) { 'https://vision-up.app/tests' }

  before do
    sign_in user
  end

  after do
    sign_out user
  end

  context 'when creating manual notifications' do
    it 'can send a notification targeting a user type' do
      teacher = create(:user, :teacher)
      parent = create(:user, :parent)
      post notifications_path,
           params: { type: 'Teacher', notification: { text:, link: } }

      expect(parent.notifications.size).to eq 0
      expect(teacher.notifications.size).to eq 1
      expect(teacher.notifications.first.text).to eq text
      expect(teacher.notifications.first.link).to eq link
    end

    it 'can send a notification targeting an organisation' do
      create_list(:organisation, 2)
      org_1_user = create(:user, :org_admin,
                          organisation_id: Organisation.first.id)
      org_2_user = create(:user, :org_admin,
                          organisation_id: Organisation.last.id)
      post notifications_path,
           params: { org_id: Organisation.first.id,
                     notification: { text:, link: } }

      expect(org_2_user.notifications.size).to eq 0
      expect(org_1_user.notifications.size).to eq 1
      expect(org_1_user.notifications.first.text).to eq text
      expect(org_1_user.notifications.first.link).to eq link
    end
  end

  context 'when updating/destroying own notifications' do
    it 'can destroy own notifications' do
      user.notify(build(:notification))
      deleted_notification = build(:notification, text: 'Deleted Notification')
      user.notify(deleted_notification)
      # id here is the index in the notifications jsonb column array
      delete notification_path(id: 1, user_id: user.id)
      expect(user.notifications.count).to eq 1
      expect(user.notifications.none?(deleted_notification)).to be true
    end

    it 'can update own notifications' do
      user.notify(build(:notification))
      expect(user.notifications.first.read).to be false
      # id here is the index in the notifications jsonb column array
      patch notification_path(id: 0, user_id: user.id)
      expect(user.notifications.first.read).to be true
    end
  end
end
