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
  let!(:student) { create(:student) }

  before do
    user = create(:user, :teacher)
    sign_in user
  end

  it 'can create a test result as teacher' do
    visit tests_path
    click_link "test_#{test.id}"
    within "#student#{student.id}_result" do
      fill_in "student#{student.id}_listening[0]", with: '2'
      fill_in "student#{student.id}_listening[1]", with: '4'
      expect(find_field('test_result_listen_percent').value).to eq('100')
      fill_in "student#{student.id}_reading[0]", with: '2'
      fill_in "student#{student.id}_reading[1]", with: '4'
      expect(find_field('test_result_read_percent').value).to eq('50')
      fill_in "student#{student.id}_speaking[0]", with: '6'
      fill_in "student#{student.id}_speaking[1]", with: '6'
      expect(find_field('test_result_speak_percent').value).to eq('86')
      fill_in "student#{student.id}_writing[1]", with: '7'
      expect(find_field('test_result_write_percent').value).to eq('70')

      expect(find_field('test_result_total_percent').value).to eq('74')
      expect(find_field('test_result_new_level').value).to eq('Sky Two')
    end
    click_button '登録する'
    expect(page).to have_content(I18n.t('create_success'))
  end
end
