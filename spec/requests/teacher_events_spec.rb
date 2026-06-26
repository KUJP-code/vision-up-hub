# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'TeacherEvents' do
  let(:pdf) { Rails.root.join('spec/example_lesson.pdf') }

  def attach_pdf(record, name)
    record.public_send(name).attach(
      io: pdf.open,
      filename: "#{name}.pdf",
      content_type: 'application/pdf'
    )
  end

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

  describe 'GET /teacher_events/:id' do
    let(:admin) { create(:user, :admin) }
    let(:teacher) { create(:user, :teacher) }
    let(:seasonal) { create(:seasonal_activity, title: 'Galaxy Summer') }

    before do
      attach_pdf(seasonal, :kindy_english_class)
      attach_pdf(seasonal, :ele_english_class)
      attach_pdf(seasonal, :galaxy_low_english_class)
      attach_pdf(seasonal, :galaxy_high_english_class)
      attach_pdf(seasonal, :galaxy_questions_english_class)
      sign_in admin
    end

    after do
      sign_out admin
    end

    it 'shows galaxy english sheets even without an activity guide' do
      get teacher_event_path(seasonal)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Kindy')
      expect(response.body).to include('Ele')
      expect(response.body).to include('Galaxy')
      expect(response.body).to include('>Low<')
      expect(response.body).to include('>High<')
      expect(response.body).to include('>Questions<')
    end

    it 'renders an edit link for admins' do
      get teacher_event_path(seasonal)

      expect(response.body).to include(edit_lesson_path(seasonal))
      expect(response.body).to include('data-turbo-frame="_top"')
    end

    it 'does not render an edit link for teachers' do
      sign_in teacher

      get teacher_event_path(seasonal)

      expect(response.body).not_to include(edit_lesson_path(seasonal))
      expect(response.body).not_to include('btn-modal-edit')
    end
  end
end
