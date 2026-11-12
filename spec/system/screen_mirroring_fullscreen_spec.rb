# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Video fullscreen presentation', :js do
  before do
    sign_in create(:user, :admin)
    @clip_name = "fullscreen-#{SecureRandom.hex(6)}.mp4"
    FileUtils.cp(Rails.root.join('spec/fixtures/files/caption-clock.mp4'), Rails.public_path.join(@clip_name))
  end

  after { FileUtils.rm_f(Rails.public_path.join(@clip_name)) if @clip_name }

  [nil, '2.7.9.1'].each do |reference|
    it "enters actual browser fullscreen and plays real media in #{reference || 'the current screen'}" do
      visit screen_mirroring_test_path(locale: :ja, reference:)
      click_button 'レッスンをはじめる' unless reference
      page.execute_script <<~JS, "/#{@clip_name}"
        const video = document.querySelector('video');
        video.src = arguments[0];
        video.loop = true;
        document.querySelectorAll('[data-kind="basic"][data-src]').forEach(button => { button.dataset.src = arguments[0]; });
      JS
      expect(page).to have_css('video', visible: :all) { page.evaluate_script('document.querySelector("video").readyState >= 2') }
      if reference
        click_button '▶ Play mirrored video'
      else
        within('.lm-lesson-tabs') { click_button 'ベーシックイングリッシュ', exact: true }
      end
      expect(page).to have_css('video', visible: :all) do
        page.evaluate_script('document.fullscreenElement === document.querySelector("video").parentElement && !document.querySelector("video").paused && document.querySelector("video").currentTime > 0')
      end
      expect(page.evaluate_script(<<~JS)).to be true
        (() => {
          const video = document.querySelector('video');
          return [video, video.parentElement].every(element => {
            const rect = element.getBoundingClientRect();
            return Math.abs(rect.left) < 1 && Math.abs(rect.top) < 1 &&
              Math.abs(rect.width - innerWidth) < 1 && Math.abs(rect.height - innerHeight) < 1;
          });
        })()
      JS
      if reference
        click_button '■ Stop'
      else
        find('button[aria-label="動画を閉じる"]').click
        expect(page).to have_css('.lm-splash-frame')
      end
      expect(page).not_to have_css(':fullscreen')
    end
  end
end
