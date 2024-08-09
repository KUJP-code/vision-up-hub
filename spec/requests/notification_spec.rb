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
      create(:user, :parent)
      post notifications_path,
           params: { user_type: 'Teacher', notification: { text:, link: } }

      notif_jobs = ActiveJob::Base.queue_adapter.enqueued_jobs
                                  .select { |j| j[:queue] == 'materials_production_notifications' }
      expect(notif_jobs.size).to eq 1
      expect(notif_jobs.first[:args].first).to eq teacher.id
    end

    it 'can send a notification targeting an organisation' do
      orgs = create_list(:organisation, 2)
      org_1_user = create(:user, :org_admin, organisation_id: orgs.first.id)
      create(:user, :org_admin, organisation_id: orgs.last.id)
      post notifications_path,
           params: { organisation_id: org_1_user.organisation_id,
                     notification: { text:, link: } }

      notif_jobs = ActiveJob::Base.queue_adapter.enqueued_jobs
                                  .select { |j| j[:queue] == 'materials_production_notifications' }
      expect(notif_jobs.size).to eq 1
      expect(notif_jobs.first[:args].first).to eq org_1_user.id
    end
  end

  context 'when updating/destroying own notifications' do
    it 'can destroy own notifications' do
      user.notify(build(:notification))
      deleted_notification = build(:notification, text: 'Deleted Notification')
      user.notify(deleted_notification)
      # id here is the index in the notifications jsonb column array
      delete notification_path(id: 1)
      expect(user.notifications.count).to eq 1
      expect(user.notifications.none?(deleted_notification)).to be true
    end

    it 'can mark own notification read' do
      user.notify(build(:notification))
      expect(user.notifications.first.read).to be false
      # id here is the index in the notifications jsonb column array
      patch notification_path(id: 0)
      expect(user.notifications.first.read).to be true
    end

    it 'can mark all notifications read' do
      user.notify(*build_list(:notification, 4))
      expect(user.notifications.size).to eq 4
      patch notification_path(id: 'all')
      expect(user.notifications.all?(&:read)).to be true
    end
  end
end
