# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'creating a plan' do
  let(:user) { create(:user, :sales) }

  before do
    create(:course, title: 'Test Course')
    sign_in user
  end

  it 'can create a plan linking organisation & course as sales' do
    visit plans_path
    click_link I18n.t('plans.index.create_plan')
    within '#plan_form' do
      fill_in 'plan_name', with: 'Test Plan'
      fill_in 'plan_student_limit', with: 100
      fill_in 'plan_total_cost', with: 1000
      select 'Test Course', from: 'plan_course_id'
      fill_in 'plan_start', with: Time.zone.today
      fill_in 'plan_finish_date', with: 12.months.from_now
      select 'KidsUP', from: 'plan_organisation_id'
    end
    click_button '登録する'
    expect(page).to have_content('Test Plan')
    expect(page).to have_content(I18n.t('plans.show.organisation', name: 'KidsUP'))
    expect(page).to have_content(I18n.t('plans.show.student_limit', limit: 100))
    expect(page).to have_content(I18n.t('plans.show.total_cost', cost: 1000))
  end
end
