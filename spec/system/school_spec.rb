# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'creating a school' do
  let(:user) { create(:user, :org_admin) }

  before do
    sign_in user
  end

  it 'can create a school as org_admin' do
    visit schools_path
    click_link I18n.t('schools.index.add_school')
    within '#school_form' do
      fill_in 'school_name', with: 'Test School'
      # Auto-populate organisation in controller (create)
    end
    click_button '登録する'
    expect(page).to have_content('Test School')
    expect(page).to have_content(I18n.t('schools.show.student_count', count: 0))
    expect(page).to have_content(user.organisation.name)
  end
end
