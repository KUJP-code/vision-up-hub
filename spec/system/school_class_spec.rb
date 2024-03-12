# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'creating a class' do
  let(:user) { create(:user, :school_manager) }
  let(:school) { create(:school, organisation: user.organisation) }

  before do
    school.students << create(:student)
    user.schools << school
    sign_in user
  end

  it 'can create a class as school manager' do
    visit school_classes_path
    click_link I18n.t('school_classes.index.create_class')
    within '#school_class_form' do
      fill_in 'school_class_name', with: 'Test Class'
      select school.name, from: 'school_class_school_id'
    end
    click_button '登録する'
    expect(page).to have_content('Test Class')
    expect(page).to have_content(I18n.t('school_classes.show.create_student'))
    expect(page).to have_selector(:button, I18n.t('school_classes.show.add_existing_student'))
  end
end
