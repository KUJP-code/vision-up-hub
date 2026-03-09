# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Homework access by role' do
  let(:organisation) { create(:organisation) }
  let(:course) { create(:course) }
  let(:plan) do
    create(
      :plan,
      organisation:,
      course:,
      start: Time.zone.today.beginning_of_week,
      finish_date: 3.months.from_now
    )
  end
  let(:english_class) { create(:english_class, level: :sky_one) }
  let(:pdf) { Rails.root.join('spec/Brett_Tanner_Resume.pdf') }

  before do
    plan
    create(:course_lesson, lesson: english_class, course:, week: 1, day: :monday)
    english_class.homework_sheet.attach(
      Rack::Test::UploadedFile.new(pdf, 'application/pdf')
    )
    english_class.homework_answers.attach(
      Rack::Test::UploadedFile.new(pdf, 'application/pdf')
    )
  end

  it 'allows teacher, school manager, and org admin to access homework index' do
    users = [
      create(:user, :teacher, organisation:),
      create(:user, :school_manager, organisation:),
      create(:user, :org_admin, organisation:)
    ]

    users.each do |user|
      sign_in user
      visit homeworks_path(course_id: course.id, level: 'Sky')
      expect(page).to have_content(I18n.t('homeworks.index.questions'))
      expect(page).to have_content(I18n.t('homeworks.index.answers'))
      sign_out user
    end
  end

  it 'allows parent to access homework files for their child' do
    school = create(:school, organisation:)
    parent = create(:user, :parent, organisation:)
    student = create(:student, organisation:, school:, parent:, level: 'sky_three')

    sign_in parent
    visit homework_resources_student_path(id: student.id)

    expect(page).to have_content(I18n.t('students.homework_resources.questions'))
    expect(page).to have_content(I18n.t('students.homework_resources.answers'))
  end
end
