# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'TeacherEvents' do
  describe 'GET /teacher_events' do
    let!(:today) { Date.current }
    let(:approval_payload) do
      [{ 'id' => '1', 'name' => 'Spec Admin', 'time' => Time.zone.now.strftime('%Y-%m-%d %H:%M:%S') }]
    end

    context 'when admin' do
      let(:admin) { create(:user, :admin) }
      let!(:other_org) { create(:organisation) }
      let!(:admin_event) do
        create(:event_activity, title: 'Admin Event', released: true, admin_approval: approval_payload)
      end
      let!(:other_event) do
        create(:event_activity, title: 'Other Org Event', released: true, admin_approval: approval_payload)
      end

      before do
        create(:organisation_lesson, organisation: admin.organisation, lesson: admin_event, event_date: today)
        create(:organisation_lesson, organisation: other_org, lesson: other_event, event_date: today)
        sign_in admin
      end

      after do
        sign_out admin
      end

      it 'shows spy and includes all org events when no organisation filter is selected' do
        get teacher_events_path(category: 'eventactivity')

        expect(response).to have_http_status(:ok)
        expect(response.body).to include('Organisation specific checker (spy)')
        expect(response.body).to include(other_org.name)
        expect(response.body).to include('Admin Event')
        expect(response.body).to include('Other Org Event')
      end

      it 'does not show spy on the outer type selection view' do
        get teacher_events_path

        expect(response).to have_http_status(:ok)
        expect(response.body).not_to include('Organisation specific checker (spy)')
      end

      it 'filters events by organisation_id when selected' do
        get teacher_events_path(category: 'eventactivity', organisation_id: other_org.id)

        expect(response).to have_http_status(:ok)
        expect(response.body).to include('Other Org Event')
        expect(response.body).not_to include('Admin Event')
      end
    end

    context 'when non-admin' do
      let(:teacher) { create(:user, :teacher) }
      let!(:other_org) { create(:organisation) }
      let!(:teacher_event) do
        create(:event_activity, title: 'Teacher Org Event', released: true, admin_approval: approval_payload)
      end
      let!(:other_event) do
        create(:event_activity, title: 'Other Org Event', released: true, admin_approval: approval_payload)
      end

      before do
        create(:organisation_lesson, organisation: teacher.organisation, lesson: teacher_event, event_date: today)
        create(:organisation_lesson, organisation: other_org, lesson: other_event, event_date: today)
        sign_in teacher
      end

      after do
        sign_out teacher
      end

      it 'ignores organisation_id query param and stays scoped to user organisation' do
        get teacher_events_path(category: 'eventactivity', organisation_id: other_org.id)

        expect(response).to have_http_status(:ok)
        expect(response.body).not_to include('Organisation specific checker (spy)')
        expect(response.body).to include('Teacher Org Event')
        expect(response.body).not_to include('Other Org Event')
      end
    end
  end
end
