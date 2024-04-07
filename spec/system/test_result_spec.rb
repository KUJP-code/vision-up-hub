# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'creating a test result', :js do
  let!(:test) do
    create(
      :test,
      level: :sky_one,
      thresholds: "Sky One:60\nSky Two:70\nSky Three:80",
      questions: "Listening: 2, 4\nReading: 6, 6\nSpeaking: 6, 8\nWriting: 10\n"
    )
  end
  let!(:student) { create(:student, level: :sky_one) }

  before do
    user = create(:user, :teacher)
    user.classes << create(:school_class)
    user.classes.first.students << student
    sign_in user
  end

  it 'can create a test result as teacher' do
    visit tests_path
    click_link "test_#{test.id}"
    within("#student#{student.id}_result", visible: false) do
      all(:fillable_field, name: 'test_result[answers][listening][]').each do |field|
        field.set '2'
      end
      expect(find_by_id('test_result_listen_percent', visible: false).value).to eq('67')

      all(:fillable_field, name: 'test_result[answers][reading][]').each do |field|
        field.set '3'
      end
      expect(find_by_id('test_result_read_percent', visible: false).value).to eq('50')

      all(:fillable_field, name: 'test_result[answers][speaking][]').each do |field|
        field.set '6'
      end
      expect(find_by_id('test_result_speak_percent', visible: false).value).to eq('86')

      all(:fillable_field, name: 'test_result[answers][writing][]').each do |field|
        field.set '10'
      end
      expect(find_by_id('test_result_write_percent', visible: false).value).to eq('100')

      expect(find_by_id('test_result_total_percent', visible: false).value).to eq('77')
      expect(find_field('test_result_new_level').value).to eq('sky_two')
    end
    click_button I18n.t('helpers.submit.create')
    expect(find_by_id('test_result_new_level').value).to eq('sky_two')
  end
end
