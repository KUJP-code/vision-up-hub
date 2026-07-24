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

  it 'filters lesson occurrences by calendar month and displays their real date and weekday' do
    get monthly_materials_path(locale: :en), params: {
      q: { course: course.id, month: '2026-01' }
    }

    expect(response).to have_http_status(:ok)
    expect(response.body).to include('January Activity')
    expect(response.body).to include('Wednesday, January 14')
    expect(response.body).not_to include('Wednesday, January 14, 2026')
    expect(response.body).not_to include('February Activity')
    expect(response.body).not_to include('W2')
  end

  it 'shows the selected calendar month input instead of course-week inputs' do
    get monthly_materials_path(locale: :en), params: {
      q: { course: course.id, month: '2026-02' }
    }

    expect(response.body).to include('type="month"')
    expect(response.body).to include('value="2026-02"')
    expect(response.body).not_to include('q[from_week]')
    expect(response.body).not_to include('q[weeks_forward]')
  end
end
