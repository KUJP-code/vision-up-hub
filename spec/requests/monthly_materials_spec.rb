# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Monthly materials' do
  let(:organisation) { create(:organisation) }
  let(:user) { create(:user, :org_admin, organisation:) }
  let(:course) { create(:course) }
  let(:january_lesson) do
    create(:daily_activity, title: 'January Activity', materials: "Paper\nGlue")
  end
  let(:february_lesson) do
    create(:daily_activity, title: 'February Activity', materials: 'Paint')
  end

  before do
    create(
      :plan,
      organisation:,
      course:,
      start: Date.new(2026, 1, 5),
      finish_date: Date.new(2026, 12, 31)
    )
    create(:course_lesson, course:, lesson: january_lesson, week: 2, day: :wednesday)
    create(:course_lesson, course:, lesson: february_lesson, week: 5, day: :monday)
    sign_in user
  end

  it 'combines every course in the organisation for the selected calendar month' do
    second_course = create(:course, title: 'Second Course')
    second_lesson = create(:daily_activity, title: 'Second Course Activity', materials: 'Card')
    create(
      :plan,
      organisation:,
      course: second_course,
      start: Date.new(2026, 1, 5),
      finish_date: Date.new(2026, 12, 31)
    )
    create(:course_lesson, course: second_course, lesson: second_lesson, week: 2, day: :wednesday)

    get monthly_materials_path(locale: :en), params: {
      month: '2026-01'
    }

    expect(response).to have_http_status(:ok)
    expect(response.body).to include('January Activity')
    expect(response.body).to include('Second Course Activity')
    expect(response.body).to include('Wednesday, January 14')
    expect(response.body).not_to include('Wednesday, January 14, 2026')
    expect(response.body).not_to include('February Activity')
    expect(response.body).not_to include('W2')
  end

  it 'places Sunday lessons at the end of their course week' do
    sunday_lesson = create(:daily_activity, title: 'Sunday Activity', materials: 'Tape')
    create(:course_lesson, course:, lesson: sunday_lesson, week: 1, day: :sunday)

    get monthly_materials_path(locale: :en), params: { month: '2026-01' }

    expect(response.body).to include('Sunday Activity')
    expect(response.body).to include('Sunday, January 11')
    expect(response.body).not_to include('Sunday, January 4')
  end

  it 'shows the selected calendar month input instead of course-week inputs' do
    get monthly_materials_path(locale: :en), params: {
      month: '2026-02'
    }

    expect(response.body).to include('type="month"')
    expect(response.body).to include('value="2026-02"')
    expect(response.body).to include('name="month"')
    expect(response.body).to include('data-controller="month-picker"')
    expect(response.body).to include('click-&gt;month-picker#open')
    expect(response.body).not_to include('name="q[')
    expect(response.body).not_to include('name="commit"')
  end

  it 'shows purchase materials but excludes basic materials' do
    january_lesson.update!(
      basic_materials: %w[Pencils Paper],
      purchase_materials: %w[Special\ Glue Paint]
    )

    get monthly_materials_path(locale: :en), params: { month: '2026-01' }

    expect(response.body).to include('Special Glue')
    expect(response.body).to include('Paint')
    expect(response.body).not_to include('Pencils')
  end

  context 'when signed in as a teacher' do
    let(:user) { create(:user, :teacher, organisation:) }

    it 'opens an attached lesson in the activity preview dialog' do
      get monthly_materials_path(locale: :en), params: {
        month: '2026-01'
      }

      preview_button = response.parsed_body.at_css(
        "button[data-dialog-src-value*='/monthly_materials/#{january_lesson.id}']"
      )

      expect(response.body).to include("id='lesson-resources'")
      expect(preview_button['data-dialog-dialog-value']).to eq('lesson-resources')
      expect(preview_button['data-dialog-frame-value']).to eq('lesson')
      expect(preview_button['data-dialog-src-value']).to include('date=2026-01-14')
      expect(preview_button['data-dialog-src-value']).to include('course_lesson_id=')
    end

    it 'uses the same lesson activity view as the teacher calendar' do
      get monthly_material_path(
        january_lesson,
        locale: :en,
        date: Date.new(2026, 1, 14),
        course_lesson_id: january_lesson.course_lessons.first.id
      )

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body.at_css('turbo-frame#lesson .dialog-content')).to be_present
      expect(response.body).to include('January Activity')
    end
  end
end
