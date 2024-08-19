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
      expect(notif_jobs.first[:args].first['user_id']).to eq teacher.id
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
      expect(notif_jobs.first[:args].first['user_id']).to eq org_1_user.id
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

    it 'can destroy all notifications' do
      user.notify(*build_list(:notification, 4))
      expect(user.notifications.size).to eq 4
      delete notification_path(id: 'all')
      expect(user.notifications.count).to eq 0
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

    it 'marks notification read when their path is visited' do
      user.notify(*build_list(:notification, 4))
      user.notify(build(:notification, text: 'Visted show route'))
      expect(user.notifications.size).to eq 5
      get notification_path(id: 4)
      expect(user.notifications.count(&:read)).to eq 1
    end
  end

  context 'when automatically notifying parent of test result' do
    let(:student) { create(:student, parent: create(:user, :parent)) }

    it 'notifies parent when student gets test result' do
      test = create(:test)
      post test_test_results_path(test),
           params: { test_result: attributes_for(:test_result,
                                                 student_id: student.id,
                                                 test_id: test.id, reason: 'test') }
      notif_jobs = ActiveJob::Base.queue_adapter.enqueued_jobs
                                  .select { |j| j[:queue] == 'materials_production_notifications' }
      expect(notif_jobs.size).to eq 1
      expect(notif_jobs.first[:args].first['user_id']).to eq student.parent_id
    end

    it 'does not enque job if student does not have parent' do
      student.update(parent_id: nil)
      test = create(:test)
      post test_test_results_path(test),
           params: { test_result: attributes_for(:test_result,
                                                 student_id: student.id,
                                                 test_id: test.id, reason: 'test') }
      notif_jobs = ActiveJob::Base.queue_adapter.enqueued_jobs
                                  .select { |j| j[:queue] == 'materials_production_notifications' }
      expect(notif_jobs.size).to eq 0
    end
  end

  context 'when automatically notifying participants of support request/message' do
    it 'notifies admins and sales on creation' do
      sales = create(:user, :sales, organisation: user.organisation)
      post support_requests_path, params: { support_request: attributes_for(:support_request) }
      notif_jobs = ActiveJob::Base.queue_adapter.enqueued_jobs
                                  .select { |j| j[:queue] == 'materials_production_notifications' }
      expect(notif_jobs.size).to eq 2
      notified_users = notif_jobs.map { |j| j[:args].first['user_id'] }
      expect(notified_users).to contain_exactly(sales.id, user.id)
    end

    it 'notifies participants (except message sender) when message sent' do
      request = create(:support_request, user: create(:user, :teacher))
      participant = create(:user, :org_admin, name: 'Participant')
      request.messages.create(attributes_for(:support_message,
                                             user_id: participant.id,
                                             support_request: request))
      post support_request_support_messages_path(request),
           params: { support_message: attributes_for(:support_message) }
      notif_jobs = ActiveJob::Base.queue_adapter.enqueued_jobs
                                  .select { |j| j[:queue] == 'materials_production_notifications' }
      expect(notif_jobs.size).to eq 2
      notified_users = notif_jobs.map { |j| j[:args].first['user_id'] }
      expect(notified_users).to contain_exactly(request.user_id, participant.id)
      expect(notified_users).not_to include(user.id)
    end
  end
end
