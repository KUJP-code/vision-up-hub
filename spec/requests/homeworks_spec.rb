# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Homeworks' do
  describe 'GET /homeworks' do
    let(:organisation) { create(:organisation) }
    let(:current_course) { create(:course, title: 'Current Course') }
    let(:expired_course) { create(:course, title: 'Old Course') }
    let(:future_course) { create(:course, title: 'Future Course') }
    let(:teacher) { create(:user, :teacher, organisation:) }
    let(:current_week_english_class) { create(:english_class, level: :sky_one) }
    let(:future_week_english_class) { create(:english_class, level: :galaxy_one) }
    let(:pdf) { Rails.root.join('spec/example_lesson.pdf') }
    let(:school) { create(:school, organisation:, ip: '*') }

    before do
      create(
        :plan,
        organisation:,
        course: current_course,
        start: Time.zone.today.beginning_of_week,
        finish_date: 3.months.from_now
      )
      create(
        :plan,
        organisation:,
        course: expired_course,
        start: 4.months.ago.beginning_of_week,
        finish_date: 2.months.ago
      )
      create(
        :plan,
        organisation:,
        course: future_course,
        start: 1.month.from_now.beginning_of_week,
        finish_date: 4.months.from_now
      )

      create(:course_lesson, lesson: current_week_english_class, course: current_course, week: 1, day: :monday)
      create(:course_lesson, lesson: future_week_english_class, course: current_course, week: 2, day: :monday)
      current_week_english_class.homework_sheet.attach(
        Rack::Test::UploadedFile.new(pdf, 'application/pdf')
      )
      current_week_english_class.homework_answers.attach(
        Rack::Test::UploadedFile.new(pdf, 'application/pdf')
      )
      future_week_english_class.homework_sheet.attach(
        Rack::Test::UploadedFile.new(pdf, 'application/pdf')
      )
      future_week_english_class.homework_answers.attach(
        Rack::Test::UploadedFile.new(pdf, 'application/pdf')
      )

      sign_in teacher
      teacher.schools << school
    end

    it 'shows only current-week homework for teachers without course tabs' do
      get homeworks_path, env: { 'REMOTE_ADDR' => '127.0.0.1' }

      expect(response).to have_http_status(:success)
      expect(response.body).to include(I18n.t('homeworks.index.date'))
      expect(response.body).to include(I18n.t('levels.sky'))
      expect(response.body).not_to include(I18n.t('levels.galaxy'))
      expect(response.body).not_to include(current_course.title)
      expect(response.body).not_to include(expired_course.title)
      expect(response.body).not_to include(future_course.title)
    end
  end
end
