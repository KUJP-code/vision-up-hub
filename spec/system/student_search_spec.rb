# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Student search', :js do
  let(:school) { create(:school, organisation_id: user.organisation_id) }
  let!(:student) do
    create(:student, student_id: 's12345678', level: :sky_one, name: 'Test Student', school_id: school.id)
  end

  before do
    sign_in user
  end

  context 'when parent' do
    let(:user) { create(:user, :parent) }

    it 'can search and claim their student by student id and level' do
      I18n.with_locale(:en) do
        visit root_path
        within '#student_search' do
          fill_in 'search_student_id', with: 's12345678'
          select 'Sky One', from: 'search_level'
          select student.school.name, from: 'search_school_id'
          click_button I18n.t('student_searches.form.search')
        end
        click_button I18n.t('student_searches.results.claim_child', child: student.name)
        expect(page).to have_css('a', text: student.name)
        expect(page).to have_content(I18n.t('update_success'))
        expect(student.reload.parent_id).to eq user.id
      end
    end

    it 'cannot claim students that already have a parent' do
      student.update(parent_id: user.id)

      I18n.with_locale(:en) do
        visit root_path
        within '#student_search' do
          fill_in 'search_student_id', with: 's12345678'
          select 'Sky One', from: 'search_level'
          select student.school.name, from: 'search_school_id'
          click_button I18n.t('student_searches.form.search')
        end
        expect(page).not_to have_content(I18n.t('student_searches.results.claim_child', child: student.name))
        expect(page).to have_content(
          I18n.t('student_searches.results.child_claimed',
                 child: student.name,
                 parent: user.email)
        )
      end
    end
  end

  context 'when school manager' do
    let(:school) { create(:school) }
    let(:user) { create(:user, :school_manager, schools: [school]) }
    let!(:extra) { create(:student, school:) }

    before do
      school.students << student
    end

    it 'can search with partial matching by name, school, level and student id' do
      visit students_path
      within '#student_search' do
        select school.name, from: 'search_school_id'
        select 'Sky One', from: 'search_level'
        fill_in 'search_student_id', with: 's12345678'
        click_button I18n.t('student_searches.form.search')
      end
      expect(page).to have_css('a', text: student.student_id)
      expect(page).not_to have_content(extra.name)
    end
  end
end
