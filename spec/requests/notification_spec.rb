# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Manual Notifications' do
  let(:user) { create(:user, :admin) }
  let(:text) { 'Test Notification' }
  let(:link) { 'https://vision-up.app/tests' }

  before do
    sign_in user
  end

  after do
    sign_out user
  end

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
