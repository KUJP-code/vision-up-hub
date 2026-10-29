# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'AI Sensei lesson prototype', :js do
  before do
    sign_in create(:user, :admin)
    visit screen_mirroring_test_path(locale: :ja)
    page.current_window.resize_to(1280, 800)
    find('.lm-week-card', match: :first)
  end

  it 'has isolated navigation with working content views and activity filters' do
    expect(page).not_to have_css('#main-nav')
    click_button 'ベーシックイングリッシュ', exact: true
    expect(page).to have_css('.lm-page-header', text: 'ベーシックイングリッシュのメニュー')
    expect(page).to have_css('.lm-week-card', count: 1)
    expect(page).to have_css('.lm-upcoming-card', text: 'Coming soon', count: 9)
    (2..10).each { |week| expect(page).to have_css('.lm-upcoming-caption', text: "第#{week}週") }
    click_button 'アクティビティ', exact: true
    %w[工作 ぬりえ 脳トレ].each do |category|
      within('.lm-filters') { click_button category, exact: true }
      expect(page).to have_css('.lm-filters button', count: 4)
      expect(page).to have_css('.lm-filters button[aria-pressed="true"]', text: category, count: 1)
      expect(page).to have_css(".lm-content-card[data-category='#{category}']", count: 1)
      expect(page).to have_css('.lm-content-card', count: 1)
    end
    within('.lm-filters') { click_button '全て', exact: true }
    expect(page).to have_css('.lm-content-card', count: 3)
    click_button 'ストーリータイム', exact: true
    expect(page).to have_css('.lm-content-card', count: 5)
    click_button 'ホーム', exact: true
    expect(page).to have_css('.lm-week-card', count: 1)
  end

  it 'opens the lesson, moves between flashcards, and restores focus on exit' do
    click_button 'レッスンをはじめる'
    expect(page).to have_css('.lm-lesson-dialog')
    expect(page.evaluate_script('document.fullscreenElement === null')).to be true
    [[1024, 768], [768, 1024], [390, 844]].each do |width, height|
      page.current_window.resize_to(width, height)
      expect(page.evaluate_script(<<~JS)).to be true
        [...document.querySelectorAll('.lm-lesson-tabs button')].every(button => {
          const rect = button.getBoundingClientRect();
          return rect.left >= 0 && rect.right <= window.innerWidth;
        })
      JS
    end
    page.current_window.resize_to(1280, 800)
    click_button 'フラッシュカード', exact: true
    expect(page).to have_css('.lm-flash-phrase', text: 'Hello!')
    expect(page).not_to have_text('1 / 3')
    expect(page.evaluate_script('getComputedStyle(document.querySelector(".lesson-mockup")).fontFamily')).to include('M PLUS 1p')
    loaded_fonts = page.driver.browser.execute_async_script(<<~JS)
      const done = arguments[arguments.length - 1];
      Promise.all([
        document.fonts.load('15px "M PLUS 1p"'),
        document.fonts.load('700 15px "M PLUS 1p"'),
        document.fonts.load('40px "Kids UP Reading Sample"', 'Hello!')
      ]).then(fonts => done(fonts.map(items => items.length))).catch(() => done([]));
    JS
    expect(loaded_fonts).to eq([1, 1, 1])
    find('button[aria-label="次のカード"]').click
    expect(page).to have_css('.lm-flash-phrase', text: 'Nice to meet you!')
    page.driver.browser.action.send_keys(:arrow_left).perform
    expect(page).to have_css('.lm-flash-phrase', text: 'Hello!')
    page.driver.browser.action.send_keys(:escape).perform
    expect(page).not_to have_css('.lm-flashcards[open]')
    expect(page).to have_css('.lm-lesson-dialog')
    find('button[aria-label="レッスンを終了"]').click
    expect(page).not_to have_css('.lm-lesson-dialog')
    expect(page.evaluate_script('document.activeElement.textContent')).to include('レッスンをはじめる')
    expect(page).not_to have_css('[inert]')
  end

  it 'opens picker resources without leaving the lesson or trapping focus behind a modal' do
    click_button 'レッスンをはじめる'
    within('.lm-lesson-tabs') { click_button 'アクティビティ', exact: true }
    within('.lm-picker') { first('button', text: 'レッスン教材').click }
    expect(page).to have_css('.lm-resource-dialog[open]', text: '教材・準備ガイド')
    within('.lm-resource-dialog') do
      expect(page).to have_button('PDFをダウンロード', disabled: true, count: 2)
    end
    within('.lm-resource-dialog') { click_button '閉じる', exact: true }
    expect(page).to have_css('.lm-picker[open]')
    within('.lm-picker') { first('button', text: '先生用ガイド').click }
    within('.lm-resource-dialog') do
      expect(page).to have_text('工作を通してキャラクターの名前')
      expect(page).to have_text('00:01:41:22 – 00:02:17:01 · 一時停止')
      find('p', text: 'Cut out Jot', visible: :all).scroll_to(:center)
      expect(page).to have_text('Cut out Jot')
      click_button '閉じる', exact: true
    end
    within('.lm-picker') { click_button '閉じる', exact: true }
    within('.lm-lesson-tabs') { click_button 'ストーリータイム', exact: true }
    expect(page).to have_css('.lm-picker .lm-content-card', count: 5)
    page.driver.browser.action.send_keys(:escape).perform
    expect(page).not_to have_css('.lm-picker[open]')
    expect(page).to have_css('.lm-lesson-dialog')
  end

  it 'controls the video and chapter guide, then returns to the splash' do
    click_button 'レッスンをはじめる'
    stub_video_playback
    within('.lm-lesson-tabs') { click_button 'ベーシックイングリッシュ', exact: true }
    expect(page).to have_css('.lm-remote')
    expect(page).to have_css('button[aria-label="一時停止"]')
    find('button[aria-label="一時停止"]').click
    expect(page).to have_css('button[aria-label="再生"]')
    within('.lm-remote') { click_button '先生用ガイド', exact: true }
    expect(page).to have_css('.lm-guide-panel', text: 'レッスンのねらい')
    select '0:39–1:21 2. ターゲット表現① Hello', from: 'チャプターを選択'
    expect(page).to have_css('.lm-guide-columns h3', text: 'ターゲット表現① Hello')
    expect(page).to have_css('.lm-time', text: '0:39 / 9:20')
    find('button[aria-label="次の章"]').click
    expect(page).to have_css('.lm-time', text: '1:21 / 9:20')
    find('button[aria-label="5秒戻る"]').click
    expect(page).to have_css('.lm-time', text: '1:16 / 9:20')
    find('summary[aria-label="再生速度"]').click
    click_button '0.75x'
    expect(page.evaluate_script('document.querySelector("video").playbackRate')).to eq(0.75)
    click_button '章末停止'
    find('button[aria-label="再生"]').click
    page.execute_script <<~JS
      const video = document.querySelector('video');
      video.currentTime = 82;
      video.dispatchEvent(new Event('timeupdate'));
    JS
    expect(page).to have_css('button[aria-label="再生"]')
    expect(page).to have_css('.lm-time', text: '1:21 / 9:20')
    [[1024, 768], [768, 1024], [390, 844]].each do |width, height|
      page.current_window.resize_to(width, height)
      expect(page.evaluate_script(<<~JS)).to be true
        [...document.querySelectorAll('.lm-controls button')].every(button => {
          const rect = button.getBoundingClientRect();
          return rect.left >= 0 && rect.right <= window.innerWidth && rect.bottom <= window.innerHeight;
        })
      JS
    end
    find('button[aria-label="動画を閉じる"]').click
    expect(page).not_to have_css('.lm-video-stage')
    expect(page).to have_css('.lm-lesson-tabs')
    expect(page).to have_css('video', count: 1, visible: :all)
  end

  it 'returns direct video launches to their original menu, filter, and button' do
    stub_video_playback
    [
      ['home', 'ホーム', 'アクティビティをはじめる', 'ホーム', :close],
      ['activities', 'アクティビティ', 'アクティビティをはじめる', 'アクティビティのメニュー', :escape],
      ['stories', 'ストーリータイム', 'ストーリーをはじめる', 'ストーリーのメニュー', :ended]
    ].each do |view, tab, launch, heading, exit_action|
      within('.lm-sidebar') { click_button tab, exact: true }
      within('.lm-filters') { click_button '工作' } if view == 'activities'
      launch_button = within(".lm-pages [data-view='#{view}']") { first('button', text: launch) }
      launch_button.click
      expect(page).to have_css('.lm-remote')

      case exit_action
      when :close then find('button[aria-label="動画を閉じる"]').click
      when :escape then page.driver.browser.action.send_keys(:escape).perform
      when :ended then page.execute_script('document.querySelector("video").dispatchEvent(new Event("ended"))')
      end

      expect(page).not_to have_css('.lm-lesson-dialog')
      expect(page).to have_css('.lm-page-header', text: heading)
      expect(page.find(':focus')).to eq(launch_button)
      expect(page).not_to have_css('[inert]')
      next unless view == 'activities'

      expect(page).to have_css('.lm-content-card', count: 1)
      expect(page).to have_css('.lm-filters button[aria-pressed="true"]', text: '工作')
    end
  end

  it 'returns videos chosen inside a lesson to its splash screen' do
    click_button 'レッスンをはじめる'
    stub_video_playback
    within('.lm-lesson-tabs') { click_button 'アクティビティ', exact: true }
    within('.lm-picker') { first('button', text: 'アクティビティをはじめる').click }
    expect(page).to have_css('.lm-remote')
    find('button[aria-label="動画を閉じる"]').click
    expect(page).to have_css('.lm-lesson-dialog .lm-splash-frame')
    expect(page).to have_css('.lm-lesson-tabs')
  end

  it 'dismisses modals from their backdrops while keeping content clicks open' do
    within('.lm-week-card') { click_button '先生用ガイド', exact: true }
    find('.lm-resource-dialog h2').click
    expect(page).to have_css('.lm-resource-dialog[open]')
    page.driver.browser.action.move_to_location(8, 8).click.perform
    expect(page).not_to have_css('.lm-resource-dialog[open]')

    click_button 'レッスンをはじめる'
    within('.lm-lesson-tabs') { click_button 'アクティビティ', exact: true }
    find('.lm-picker .lm-content-card h2', match: :first).click
    expect(page).to have_css('.lm-picker[open]')
    page.driver.browser.action.move_to_location(8, 8).click.perform
    expect(page).not_to have_css('.lm-picker[open]')
    expect(page).to have_css('.lm-lesson-dialog')

    within('.lm-lesson-tabs') { click_button 'ストーリータイム', exact: true }
    expect(page).to have_css('.lm-picker[open]')
    page.driver.browser.action.move_to_location(8, 8).click.perform
    expect(page).not_to have_css('.lm-picker[open]')

    click_button 'フラッシュカード', exact: true
    find('.lm-flash-phrase').click
    expect(page).to have_css('.lm-flashcards[open]')
    page.driver.browser.action.move_to_location(100, 100).click.perform
    expect(page).not_to have_css('.lm-flashcards[open]')
    expect(page).to have_css('.lm-lesson-dialog')
  end

  it 'switches sections from the navigation inside the content modal' do
    click_button 'レッスンをはじめる'
    stub_video_playback
    within('.lm-lesson-tabs') { click_button 'アクティビティ', exact: true }
    expect(page).to have_css('.lm-picker[open] .lm-picker-navigation .lm-lesson-tabs')
    find('.lm-picker-navigation').click(x: 8, y: 8, offset: :top_left)
    expect(page).to have_css('.lm-picker[open]')
    within('.lm-picker-navigation') { click_button 'ストーリータイム', exact: true }
    expect(page).to have_css('.lm-picker[open] .lm-content-card', count: 5)
    within('.lm-picker-navigation') { click_button 'アクティビティ', exact: true }
    expect(page).to have_css('.lm-picker[open] .lm-content-card', count: 3)
    within('.lm-picker-navigation') { click_button 'フラッシュカード', exact: true }
    expect(page).not_to have_css('.lm-picker[open]')
    expect(page).to have_css('.lm-flashcards[open]')
    expect(page).to have_css('.lm-flash-crop[viewBox="540 180 520 665"]')
    find('button[aria-label="次のカード"]').click
    expect(page).to have_css('.lm-flash-crop[viewBox="1070 380 620 470"]')
    within('.lm-flashcards') { click_button '閉じる', exact: true }
    within('.lm-lesson-tabs') { click_button 'アクティビティ', exact: true }
    within('.lm-picker-navigation') { click_button 'ベーシックイングリッシュ', exact: true }
    expect(page).not_to have_css('.lm-picker[open]')
    expect(page).to have_css('.lm-remote')
    find('button[aria-label="動画を閉じる"]').click
    expect(page).to have_css('.lm-lesson-menu .lm-lesson-tabs')
  end

  it 'shows previews for future weeks and restores the current week on return' do
    click_button '来週', exact: true
    expect(page).to have_css('.lm-upcoming-card', text: 'Coming soon')
    expect(page).not_to have_button('レッスンをはじめる')
    expect(page).not_to have_button('アクティビティをはじめる')
    expect(page).to have_css('.lm-upcoming-caption', text: '第2週')
    click_button '来週', exact: true
    expect(page).to have_css('.lm-upcoming-caption', text: '第3週')
    2.times { click_button '先週', exact: true }
    expect(page).to have_button('レッスンをはじめる')
    expect(page).not_to have_css('.lm-upcoming-card')
  end

  it 'uses each activity video and its own teacher guide, chapters, and pause points' do
    stub_video_playback
    [
      ['あいさつの工作', '1225144025', 'はさみ', 'Cut out Jot', '00:04:02:10'],
      ['なまえをなぞって色ぬり', '1225144026', 'クレヨン', 'Trace your name', '00:04:19:10'],
      ['Helloの点つなぎ', '1225144027', '点つなぎ', 'Find one', '00:05:52:00']
    ].each_with_index do |(title, video_id, preparation, instruction, ending), index|
      card = find(".lm-pages [data-view='home'] .lm-content-card", text: title)
      within(card) { click_button '先生用ガイド', exact: true }
      within('.lm-resource-dialog') do
        expect(page).to have_text(preparation)
        find('p', text: instruction, visible: :all).scroll_to(:center)
        expect(page).to have_text(instruction)
        find('p', text: ending, visible: :all).scroll_to(:center)
        expect(page).to have_text(ending)
        click_button '閉じる', exact: true
      end
      within(card) { click_button 'アクティビティをはじめる', exact: true }
      expect(page).to have_css('.lm-remote')
      expect(page.evaluate_script('document.querySelector("video").src')).to include("#{video_id}.m3u8")
      within('.lm-remote') { click_button '先生用ガイド', exact: true }
      expect(page).to have_css('.lm-guide-panel', text: preparation)
      expect(page).to have_css('.lm-guide-heading h2', text: title)
      find('select[data-screen-mirroring-test-target="chapterPicker"]').find_all('option')[2].select_option
      expect(page).to have_css('.lm-guide-columns', text: instruction) if index == 1
      next_time = page.evaluate_script('document.querySelector("video").currentTime')
      expect(next_time).to be_within(0.001).of([101 + 22.0 / 24, 99 + 14.0 / 24, 161 + 13.0 / 24][index])
      if index.zero?
        page.execute_script <<~JS
          const video = document.querySelector('video');
          video.currentTime = 137.2;
          video.dispatchEvent(new Event('timeupdate'));
        JS
        expect(page).to have_css('button[aria-label="再生"]')
        expect(page.evaluate_script('document.querySelector("video").currentTime')).to be_within(0.001).of(137 + 1.0 / 24)
        find('button[aria-label="再生"]').click
        expect(page).to have_css('button[aria-label="一時停止"]')
      end
      find('button[aria-label="動画を閉じる"]').click
      expect(page).not_to have_css('.lm-lesson-dialog')
    end
  end

  it 'fades the remote after five idle seconds and restores it for pointer, touch, and keyboard use' do
    click_button 'レッスンをはじめる'
    stub_video_playback
    within('.lm-lesson-tabs') { click_button 'ベーシックイングリッシュ', exact: true }
    expect(page).to have_css('.lm-remote')
    expect(page).not_to have_css('.lm-controls-hidden')
    expect(page).to have_css('.lm-controls-hidden', wait: 7)
    expect(page).not_to have_css('.lm-remote')
    expect(page.evaluate_script('document.querySelector(".lm-remote").inert')).to be true

    %w[pointermove pointerdown keydown].each do |event|
      page.execute_script <<~JS, event
        const stage = document.querySelector('.lm-video-stage');
        stage.dispatchEvent(new Event(arguments[0], { bubbles: true }));
      JS
      expect(page).to have_css('.lm-remote')
      expect(page.evaluate_script('document.querySelector(".lm-remote").inert')).to be false
    end
    page.execute_script('document.dispatchEvent(new Event("pointerup"))')
    find('button[aria-label="一時停止"]').click
    # A paused lesson keeps the controls visible even after the idle deadline.
    expect(page).to have_css('button[aria-label="再生"]')
    page.driver.browser.execute_async_script('setTimeout(arguments[arguments.length - 1], 5300)')
    expect(page).to have_css('.lm-remote')
    find('button[aria-label="再生"]').click
    expect(page).to have_css('.lm-controls-hidden', wait: 7)
    page.execute_script('document.querySelector(".lm-video-stage").dispatchEvent(new Event("pointermove"))')
    find('button[aria-label="動画を閉じる"]').click
    expect(page).not_to have_css('.lm-video-stage')
  end

  private

  def stub_video_playback
    # Exercise the real DOM controls with a deterministic media clock, independent
    # of network timing and the browser's support for Vimeo's HLS source.
    page.execute_script <<~JS
      const video = document.querySelector('video');
      video.removeAttribute('src');
      video.load = () => {};
      let clock = 0;
      let source = '';
      Object.defineProperties(video, {
        currentTime: { get: () => clock, set: value => { clock = value; } },
        src: { get: () => source, set: value => { source = value; } },
        duration: { get: () => 560.125 },
        readyState: { get: () => 1 },
        paused: { get: () => video.demoPaused !== false },
        seeking: { get: () => false }
      });
      video.play = () => {
        video.demoPaused = false;
        video.dispatchEvent(new Event('play'));
        return Promise.resolve();
      };
      video.pause = () => {
        video.demoPaused = true;
        video.dispatchEvent(new Event('pause'));
      };
      document.querySelector('.lm-video-stage').requestFullscreen = () => Promise.resolve();
    JS
  end
end
