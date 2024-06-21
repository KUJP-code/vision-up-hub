# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'language switcher' do
  let(:user) { create(:user, :writer) }

  before do
    sign_in user
    allow(I18n).to receive(:with_locale).and_call_original
  end

  it 'can switch current page language to English' do
    I18n.with_locale(:ja) do
      visit '/'
      click_on 'Switch to EN'
      expect(I18n).to have_received(:with_locale).with('en').once
    end
  end

  it 'retains selected locale when clicking links to another page' do
    I18n.with_locale(:ja) do
      visit '/'
      click_on 'Switch to EN'
      expect(I18n).to have_received(:with_locale).with('en').once
      click_on 'Lessons'
      expect(I18n).to have_received(:with_locale).with('en').exactly(2).times
    end
  end

  it 'retains params when switching language' do
    I18n.with_locale(:ja) do
      visit new_lesson_path(type: 'EnglishClass')
      click_on 'Switch to EN'
      expect(I18n).to have_received(:with_locale).with('en').once
      expect(page).to have_current_path new_lesson_path(locale: :en,
                                                        type: 'EnglishClass')
    end
  end
end
