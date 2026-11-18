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
    expect(page).to have_css('.lm-week-card', count: 3)
    expect(page).to have_css('.lm-upcoming-card', text: 'Coming soon', count: 8)
    ((2..10).to_a - [6]).each { |week| expect(page).to have_css('.lm-upcoming-caption', text: "第#{week}週") }
    click_button 'アクティビティ', exact: true
    { '工作' => 5, 'ぬりえ' => 1, '脳トレ' => 3 }.each do |category, count|
      within('.lm-filters') { click_button category, exact: true }
      expect(page).to have_css('.lm-filters button', count: 4)
      expect(page).to have_css('.lm-filters button[aria-pressed="true"]', text: category, count: 1)
      expect(page).to have_css(".lm-content-card[data-category='#{category}']", count:)
      expect(page).to have_css('.lm-content-card', count:)
    end
    within('.lm-filters') { click_button '全て', exact: true }
    expect(page).to have_css('.lm-content-card', count: 9)
    click_button 'ストーリータイム', exact: true
    expect(page).to have_css('.lm-content-card', count: 2)
    click_button 'ホーム', exact: true
    expect(page).to have_css('.lm-week-card', count: 1)
  end

  it 'sends opt-in local viewport diagnostics and marks the actual page edge' do
    expect(page).not_to have_css('[data-layout-probe-marker]')
    visit ai_sensei_path(locale: :ja, layout_probe: '1')
    expect(page).to have_css('.lesson-mockup[data-layout-probe-status="sent"]')
    expect(page).to have_css('[data-layout-probe-marker]')
    report = JSON.parse(File.readlines(Rails.root.join('tmp/ai-sensei-layout-reports-test.jsonl')).last)
    expect(report['dimensions']['inner_width']).to be > 0
    expect(report['elements'].find { |element| element['name'] == '.lm-page-header' }['top']).to eq(0)
    expect(report['elements'].find { |element| element['name'] == '[data-layout-probe-marker]' }['top']).to eq(0)
  ensure
    FileUtils.rm_f(Rails.root.join('tmp/ai-sensei-layout-reports-test.jsonl'))
  end

  it 'keeps the shared home, menu, and exit icons in the navigation colour on focus' do
    %w[home activities home].each do |view|
      find(".lm-sidebar [data-view='#{view}']").click
      expect(page.evaluate_script(<<~JS)).to be true
        [...document.querySelectorAll('.lm-sidebar .lm-shared-icon')].every(icon =>
          [...icon.querySelectorAll('path')].every(path => getComputedStyle(path).fill === getComputedStyle(icon.closest('button, a')).color)
        )
      JS
    end
    home = find('.lm-sidebar [data-view="home"]')
    page.execute_script('arguments[0].focus()', home)
    expect(page.evaluate_script('getComputedStyle(document.querySelector(".lm-sidebar [data-view=home] svg path")).fill')).to eq('rgb(255, 255, 255)')
  end

  it 'scrolls the menu content with native touch gestures while the app frame stays at the page edges' do
    page.current_window.resize_to(1024, 768)
    browser = page.driver.browser
    browser.execute_cdp('Emulation.setTouchEmulationEnabled', enabled: true, maxTouchPoints: 2)
    gesture = lambda do |distance|
      browser.execute_cdp('Input.synthesizeScrollGesture', x: 750, y: 400,
                          yDistance: distance, speed: 900, gestureSourceType: 'touch')
    end
    gesture.call(-220)
    expect(page.evaluate_script('document.querySelector(".lm-workspace").scrollTop')).to be > 0
    [0, 1].each do |edge|
      page.execute_script <<~JS, edge
        const workspace = document.querySelector('.lm-workspace');
        workspace.scrollTop = arguments[0] ? workspace.scrollHeight : 0;
      JS
      gesture.call(edge.zero? ? 180 : -180)
      expect(page.evaluate_script(<<~JS)).to be true
        (() => {
          const workspace = document.querySelector('.lm-workspace');
          const frame = document.querySelector('.lesson-mockup').getBoundingClientRect();
          const header = document.querySelector('.lm-page-header').getBoundingClientRect();
          const sidebar = document.querySelector('.lm-sidebar').getBoundingClientRect();
          return scrollY === 0 && document.scrollingElement.scrollHeight <= innerHeight &&
            frame.top === 0 && Math.abs(frame.bottom - innerHeight) < 1 &&
            header.top === 0 && sidebar.top === 0 && Math.abs(sidebar.bottom - innerHeight) < 1 &&
            workspace.scrollTop >= 0 && workspace.scrollTop <= workspace.scrollHeight - workspace.clientHeight + 1;
        })()
      JS
    end
    within('.lm-sidebar') { click_button 'ストーリータイム', exact: true }
    expect(page.evaluate_script('document.querySelector(".lm-workspace").scrollTop')).to eq(0)
  ensure
    browser&.execute_cdp('Emulation.setTouchEmulationEnabled', enabled: false)
  end

  it 'opens and controls the isolated 2.8.3.1 comparison player' do
    visit screen_mirroring_test_path(locale: :ja, reference: '2.8.3.1')
    expect(page).to have_css('[data-controller="screen-mirroring-2831-reference"]')
    click_button 'レッスンをはじめる ▶', exact: true
    stub_video_playback
    within('.lm-lesson-menu') { click_button 'ベーシックイングリッシュ' }
    expect(page).to have_css('.lm-remote')
    expect(page).to have_button('Ⅱ 一時停止')
    click_button 'Ⅱ 一時停止', exact: true
    expect(page).to have_button('▶ 再生')
    click_button '▶ 再生', exact: true
    expect(page).to have_button('Ⅱ 一時停止')
    click_button '■ 停止', exact: true
    expect(page).not_to have_css('.lm-video-stage')
    expect(page).to have_css('.lm-lesson-menu')
  end

  it 'opens the lesson, moves between flashcards, and restores focus on exit' do
    click_button 'レッスンをはじめる'
    expect(page).to have_css('.lm-lesson-dialog')
    expect(page.evaluate_script(<<~JS)).to be true
      (() => {
        const stage = document.querySelector('.lm-video-stage');
        const bounds = stage.getBoundingClientRect();
        return !stage.hidden && stage.inert && stage.getAttribute('aria-hidden') === 'true' &&
          bounds.width > 0 && Math.abs(bounds.width / bounds.height - 16 / 9) < 0.01;
      })()
    JS
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
    page.execute_script <<~JS
      document.addEventListener('playing', event => {
        if (event.target instanceof HTMLAudioElement) event.target.dataset.played = 'true';
      }, true);
    JS
    [['Hello!', 'hello'], ['Nice to meet you!', 'nice-to-meet-you'], ['See you!', 'see-you']].each do |phrase, asset|
      expect(page).to have_css('.lm-flash-phrase', exact_text: phrase)
      expect(page).to have_css(".lm-flash-artwork[src*='week-1/#{asset}-']") { |image|
        page.evaluate_script('arguments[0].naturalWidth > 0', image)
      }
      find('button[aria-label="音声を聞く"]').click
      expect(page).to have_css("audio[src*='week-1/#{asset}-'][data-played='true']", visible: :all, wait: 5)
      find('button[aria-label="次のカード"]').click unless phrase == 'See you!'
    end
    page.driver.browser.action.send_keys(:arrow_left).perform
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

  it 'fills the lesson viewport without scrolling the page underneath and restores the menu position on exit' do
    page.current_window.resize_to(390, 844)
    launch = find('.lm-week-card button', text: 'レッスンをはじめる', match: :first)
    launch.scroll_to(:center)
    page.execute_script('document.querySelector(".lm-workspace").scrollTo(0, 100)')
    scroll_position = page.evaluate_script('document.querySelector(".lm-workspace").scrollTop')
    expect(scroll_position).to be > 0
    launch.click

    [[390, 844], [1024, 768], [768, 1024]].each do |width, height|
      page.current_window.resize_to(width, height)
      page.execute_script('window.scrollBy(100, 200)')
      expect(page.evaluate_script(<<~JS)).to be true
        (() => {
          const rect = document.querySelector('.lm-lesson-dialog').getBoundingClientRect();
          return window.scrollX === 0 && window.scrollY === 0 &&
            document.scrollingElement.scrollHeight <= innerHeight &&
            document.scrollingElement.scrollWidth <= innerWidth &&
            rect.left === 0 && rect.top === 0 &&
            Math.abs(rect.width - innerWidth) < 1 && Math.abs(rect.height - innerHeight) < 1;
        })()
      JS
    end

    page.current_window.resize_to(390, 660)
    within('.lm-lesson-tabs') { click_button 'アクティビティ', exact: true }
    page.execute_script('document.querySelector(".lm-picker-scroll").scrollTop = 100')
    expect(page.evaluate_script('document.querySelector(".lm-picker-scroll").scrollTop')).to be > 0
    expect(page.evaluate_script('window.scrollY')).to eq(0)
    within('.lm-picker') { find('button[aria-label="閉じる"]').click }
    page.current_window.resize_to(390, 844)
    find('button[aria-label="レッスンを終了"]').click
    expect(page.evaluate_script('document.querySelector(".lm-workspace").scrollTop')).to be_within(1).of(scroll_position)
    page.execute_script('document.querySelector(".lm-workspace").scrollBy(0, 100)')
    expect(page.evaluate_script('document.querySelector(".lm-workspace").scrollTop')).to be > scroll_position
    expect(page.evaluate_script('window.scrollY')).to eq(0)
  end

  it 'keeps the menu pinned to the page top when Safari reports a visual viewport offset' do
    click_button 'レッスンをはじめる'
    page.execute_script <<~JS
      const viewport = window.visualViewport;
      window.lessonViewport = {offsetTop: 24, offsetLeft: 16, width: innerWidth - 32, height: innerHeight - 48};
      Object.keys(window.lessonViewport).forEach(name => {
        Object.defineProperty(viewport, name, {configurable: true, get: () => window.lessonViewport[name]});
      });
    JS
    %w[resize scroll].each do |event|
      page.execute_script('window.visualViewport.dispatchEvent(new Event(arguments[0]))', event)
      expect(page.evaluate_script(<<~JS)).to be true
        (() => {
          const lesson = document.querySelector('.lm-lesson-dialog').getBoundingClientRect();
          const menu = document.querySelector('.lm-lesson-menu').getBoundingClientRect();
          return lesson.top === 0 && lesson.left === 0 && menu.top === 0 &&
            Math.abs(lesson.width - innerWidth) < 0.1 && Math.abs(lesson.height - innerHeight) < 0.1;
        })()
      JS
      page.execute_script('window.lessonViewport = {offsetTop: 0, offsetLeft: 0, width: innerWidth, height: innerHeight}')
    end
  end

  it 'centre-crops the artwork below the menu at its natural aspect ratio and scales speech hotspots with it' do
    click_button 'レッスンをはじめる'
    expect(page).to have_css('.lm-splash') { page.evaluate_script('document.querySelector(".lm-splash").naturalWidth > 0') }
    [[1280, 800], [1024, 768], [768, 1024], [390, 844]].each do |width, height|
      page.current_window.resize_to(width, height)
      expect(page.evaluate_script(<<~JS)).to be true
        (() => {
          const menu = document.querySelector('.lm-lesson-menu').getBoundingClientRect();
          const slot = document.querySelector('.lm-splash-viewport').getBoundingClientRect();
          const frame = document.querySelector('.lm-splash-frame').getBoundingClientRect();
          const image = document.querySelector('.lm-splash');
          const picture = image.getBoundingClientRect();
          const hello = document.querySelector('.lm-speech-hello').getBoundingClientRect();
          const painted = document.elementFromPoint(slot.left + slot.width / 2, slot.top + slot.height / 2);
          return menu.top === 0 && Math.abs(slot.top - menu.bottom) < 0.1 &&
            Math.abs(slot.bottom - innerHeight) < 0.1 && slot.left === 0 && Math.abs(slot.width - innerWidth) < 0.1 &&
            Math.abs(frame.width / frame.height - image.naturalWidth / image.naturalHeight) < 0.001 &&
            frame.width >= slot.width && frame.height >= slot.height &&
            Math.abs((frame.left + frame.right) / 2 - (slot.left + slot.right) / 2) < 0.1 &&
            Math.abs((frame.top + frame.bottom) / 2 - (slot.top + slot.bottom) / 2) < 0.1 &&
            Math.abs(picture.width - frame.width) < 0.1 && Math.abs(picture.height - frame.height) < 0.1 &&
            Math.abs(hello.left - (frame.left + frame.width * 0.48)) < 1 &&
            Math.abs(hello.top - (frame.top + frame.height * 0.14)) < 1 &&
            !!painted.closest('.lm-splash-frame');
        })()
      JS
    end
  end

  it 'cancels touch overscroll on the lesson and panel boundaries while preserving panel scrolling and pinch zoom' do
    click_button 'レッスンをはじめる'
    install_lesson_drag_probe
    [60, -60].each do |delta|
      expect(page.evaluate_script('window.lessonDragAllowed(".lm-splash", arguments[0])', delta)).to be false
      expect(page.evaluate_script('window.lessonDragAllowed(".lm-lesson-menu", arguments[0])', delta)).to be false
    end
    expect(page.evaluate_script('window.lessonDragAllowed(".lm-splash", 60, 2)')).to be true
    page.current_window.resize_to(390, 660)
    within('.lm-lesson-tabs') { click_button 'アクティビティ', exact: true }
    page.execute_script('document.querySelector(".lm-picker-scroll").scrollTop = 0')
    expect(page.evaluate_script('window.lessonDragAllowed(".lm-picker-scroll h2", 60)')).to be false
    expect(page.evaluate_script('window.lessonDragAllowed(".lm-picker-scroll h2", -60)')).to be true
    page.execute_script('document.querySelector(".lm-picker-scroll").scrollTop = 100')
    [60, -60].each do |delta|
      expect(page.evaluate_script('window.lessonDragAllowed(".lm-picker-scroll h2", arguments[0])', delta)).to be true
    end
    page.execute_script <<~JS
      const panel = document.querySelector('.lm-picker-scroll');
      panel.scrollTop = panel.scrollHeight;
    JS
    expect(page.evaluate_script('window.lessonDragAllowed(".lm-picker-scroll h2", -60)')).to be false
    within('.lm-picker') { find('button[aria-label="閉じる"]').click }
    find('button[aria-label="レッスンを終了"]').click
    page.execute_script('document.querySelector(".lm-workspace").scrollTop = 0')
    expect(page.evaluate_script('window.lessonDragAllowed(".lm-pages", 60)')).to be false
    expect(page.evaluate_script('window.lessonDragAllowed(".lm-pages", -60)')).to be true
  end

  it 'opens picker resources without leaving the lesson or trapping focus behind a modal' do
    click_button 'レッスンをはじめる'
    within('.lm-lesson-tabs') { click_button 'アクティビティ', exact: true }
    within('.lm-picker') do
      expect(page).to have_css('a[download]', text: 'レッスン教材', count: 2)
    end
    within('.lm-picker') { first('button', text: '先生用ガイド').click }
    within('.lm-resource-dialog') do
      expect(page).to have_text('工作を通してキャラクターの名前')
      expect(page).to have_text('00:01:41:22 – 00:02:17:01 · 一時停止')
      find('p', text: 'Cut out / 切り抜く', visible: :all).scroll_to(:center)
      expect(page).to have_text('Cut out / 切り抜く')
      find('button[aria-label="閉じる"]').click
    end
    within('.lm-picker') { find('button[aria-label="閉じる"]').click }
    within('.lm-lesson-tabs') { click_button 'ストーリータイム', exact: true }
    expect(page).to have_css('.lm-picker .lm-content-card', count: 2)
    page.driver.browser.action.send_keys(:escape).perform
    expect(page).not_to have_css('.lm-picker[open]')
    expect(page).to have_css('.lm-lesson-dialog')
  end

  it 'uses one X per modal and shows its focus indicator only for keyboard navigation' do
    within('.lm-week-card') { click_button '先生用ガイド', exact: true }
    resource = find('.lm-resource-dialog[open]')
    expect(resource).to have_css('button[aria-label="閉じる"]', count: 1)
    expect(resource).not_to have_text('閉じる')
    close = resource.find('button[aria-label="閉じる"]')
    expect(close).to have_css('svg')
    expect(page.evaluate_script('getComputedStyle(arguments[0]).outlineStyle', close)).to eq('none')
    page.driver.browser.action.send_keys(:tab).perform
    page.execute_script('arguments[0].focus()', close)
    expect(page.evaluate_script('getComputedStyle(arguments[0]).outlineColor', close)).to eq('rgb(101, 87, 127)')
    expect(page.evaluate_script('getComputedStyle(arguments[0]).outlineWidth', close)).to eq('3px')
    close.click

    click_button 'レッスンをはじめる'
    within('.lm-lesson-tabs') { click_button 'アクティビティ', exact: true }
    picker = find('.lm-picker[open]')
    expect(picker).to have_css('button[aria-label="閉じる"]', count: 1)
    expect(picker).not_to have_text('閉じる')
    expect(page.evaluate_script('getComputedStyle(document.querySelector(".lm-picker .lm-modal-close")).outlineStyle')).to eq('none')
    within(picker) { find('button[aria-label="閉じる"]').click }

    click_button 'フラッシュカード', exact: true
    flashcards = find('.lm-flashcards[open]')
    expect(flashcards).to have_css('button[aria-label="閉じる"]', count: 1)
    expect(flashcards).not_to have_text('閉じる')
    expect(flashcards).to have_css('.lm-flashcard .lm-modal-close svg')
    within(flashcards) { find('button[aria-label="閉じる"]').click }
    expect(page).not_to have_css('.lm-flashcards[open]')
    expect(page).to have_css('.lm-lesson-tabs')
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
    select '0:34–3:53 2. 今週のフレーズ、ワードを確認', from: 'チャプターを選択'
    expect(page).to have_css('.lm-guide-columns h3', text: '今週のフレーズ、ワードを確認')
    expect(page).to have_css('.lm-time', text: '0:34 / 9:20')
    find('button[aria-label="次の章"]').click
    expect(page).to have_css('.lm-time', text: '3:53 / 9:20')
    expect(page).to have_css('.lm-guide-columns', text: '00:03:49:13 – 00:05:10:15')
    expect(page).to have_css('.lm-guide-columns', text: '00:05:10:17 – 00:06:21:06')
    find('button[aria-label="5秒戻る"]').click
    expect(page).to have_css('.lm-time', text: '3:48 / 9:20')
    find('summary[aria-label="再生速度"]').click
    click_button '0.75x'
    expect(page.evaluate_script('document.querySelector("video").playbackRate')).to eq(0.75)
    click_button '章末停止'
    find('button[aria-label="再生"]').click
    page.execute_script <<~JS
      const video = document.querySelector('video');
      video.currentTime = 234;
      video.dispatchEvent(new Event('timeupdate'));
    JS
    expect(page).to have_css('button[aria-label="再生"]')
    expect(page).to have_css('.lm-time', text: '3:53 / 9:20')
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
    expect(page).not_to have_css('.lm-video-stage.fixed')
    expect(page.evaluate_script('document.querySelector(".lm-video-stage").inert')).to be true
    expect(page).to have_css('.lm-lesson-tabs')
    expect(page).to have_css('video', count: 1, visible: :all)
  end

  it 'offers native AirPlay routing and keeps the wireless remote visible and usable on iPad sizes' do
    click_button 'レッスンをはじめる'
    stub_video_playback
    page.execute_script <<~JS
      const video = document.querySelector('video');
      video.webkitShowPlaybackTargetPicker = () => { video.demoAirPlayRequests = (video.demoAirPlayRequests || 0) + 1; };
      video.webkitCurrentPlaybackTargetIsWireless = false;
      video.dispatchEvent(new Event('webkitcurrentplaybacktargetiswirelesschanged'));
    JS
    within('.lm-lesson-tabs') { click_button 'ベーシックイングリッシュ', exact: true }
    click_button 'AirPlay', exact: true
    expect(page.evaluate_script('document.querySelector("video").demoAirPlayRequests')).to eq(1)
    page.execute_script <<~JS
      const video = document.querySelector('video');
      video.webkitCurrentPlaybackTargetIsWireless = true;
      video.dispatchEvent(new Event('webkitcurrentplaybacktargetiswirelesschanged'));
    JS
    expect(page).to have_button('AirPlay 接続中', exact: true)
    [[1024, 768], [768, 1024], [390, 844]].each do |width, height|
      page.current_window.resize_to(width, height)
      expect(page.evaluate_script(<<~JS)).to be true
        [...document.querySelectorAll('.lm-controls button')].filter(button => button.getClientRects().length).every(button => {
          const rect = button.getBoundingClientRect();
          return rect.left >= 0 && rect.right <= innerWidth && rect.bottom <= innerHeight;
        })
      JS
    end
    page.driver.browser.execute_async_script('setTimeout(arguments[arguments.length - 1], 5300)')
    expect(page).to have_css('.lm-remote')
    expect(page).not_to have_css('.lm-controls-hidden')
    page.execute_script <<~JS
      const video = document.querySelector('video');
      video.webkitCurrentPlaybackTargetIsWireless = false;
      video.dispatchEvent(new Event('webkitcurrentplaybacktargetiswirelesschanged'));
    JS
    expect(page).to have_button('AirPlay', exact: true)
  end

  it 'scrolls the video guide within its bounds when AirPlay is active' do
    page.current_window.resize_to(768, 1024)
    click_button 'レッスンをはじめる'
    stub_video_playback
    install_lesson_drag_probe
    within('.lm-lesson-tabs') { click_button 'ベーシックイングリッシュ', exact: true }
    within('.lm-remote') { click_button '先生用ガイド', exact: true }
    select '3:53–6:15 3. 単語・表現チェッククイズ', from: 'チャプターを選択'
    guide = find('.lm-guide-panel')
    max_scroll = page.evaluate_script('arguments[0].scrollHeight - arguments[0].clientHeight', guide)
    expect(max_scroll).to be > 60
    expect(page.evaluate_script('window.lessonDragAllowed(".lm-guide-columns p", -60)')).to be true

    page.execute_script <<~JS
      const video = document.querySelector('video');
      video.webkitCurrentPlaybackTargetIsWireless = true;
      video.dispatchEvent(new Event('webkitcurrentplaybacktargetiswirelesschanged'));
    JS
    expect(page.evaluate_script('getComputedStyle(arguments[0]).touchAction', guide)).to eq('pinch-zoom')
    expect(page.evaluate_script('window.lessonDragAllowed(".lm-guide-columns p", -60)')).to be false
    expect(page.evaluate_script('arguments[0].scrollTop', guide)).to eq(60)
    expect(page.evaluate_script(<<~JS)).to be true
      (() => {
        const text = document.querySelector('[data-screen-mirroring-test-target="guide"]');
        const previous = text.firstChild;
        document.querySelector('video').dispatchEvent(new Event('timeupdate'));
        return text.firstChild === previous;
      })()
    JS
    expect(page.evaluate_script('window.lessonDragAllowed(".lm-guide-columns p", -10000)')).to be false
    expect(page.evaluate_script('arguments[0].scrollTop', guide)).to eq(max_scroll)
    expect(page.evaluate_script('window.lessonDragAllowed(".lm-guide-columns p", 10000)')).to be false
    expect(page.evaluate_script('arguments[0].scrollTop', guide)).to eq(0)
    expect(page.evaluate_script('window.lessonDragAllowed(".lm-guide-columns p", -60, 2)')).to be true
    expect(page.evaluate_script(<<~JS, guide)).to eq([false, 40])
      ((guide) => {
        const allowed = guide.dispatchEvent(new WheelEvent('wheel', {deltaY: 40, bubbles: true, cancelable: true}));
        return [allowed, guide.scrollTop];
      })(arguments[0])
    JS

    page.execute_script <<~JS
      const video = document.querySelector('video');
      video.webkitCurrentPlaybackTargetIsWireless = false;
      video.dispatchEvent(new Event('webkitcurrentplaybacktargetiswirelesschanged'));
    JS
    expect(page.evaluate_script('getComputedStyle(arguments[0]).touchAction', guide)).to eq('auto')
    expect(page.evaluate_script('window.lessonDragAllowed(".lm-guide-columns p", -60)')).to be true
    expect(page.evaluate_script('window.scrollY')).to eq(0)
  end

  it 'returns direct video launches to their original menu, filter, and button' do
    stub_video_playback
    [
      ['home', 'ホーム', 'アクティビティをはじめる', '今週のレッスン', :close],
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

      expect(page).to have_css('.lm-content-card', count: 5)
      expect(page).to have_css('.lm-filters button[aria-pressed="true"]', text: '工作')
    end
  end

  it 'prepares a direct card before click and starts it without reloading, pausing, or seeking' do
    stub_video_playback
    launch = first(".lm-pages [data-view='home'] [data-content-key='activity-1'][data-src]")
    page.execute_script <<~JS, launch
      arguments[0].dispatchEvent(new PointerEvent('pointerdown', { bubbles: true }));
    JS
    expect(page.evaluate_script('document.querySelector("video").demoSourceChanges')).to eq(1)
    launch.click
    expect(page).to have_css('.lm-remote')
    # A second queued click must not request fullscreen/play again or change
    # the return destination of a direct launch.
    page.execute_script <<~JS, launch
      arguments[0].dispatchEvent(new MouseEvent('click', { bubbles: true }));
    JS
    expect(page.evaluate_script('document.querySelector("video").demoStart')).to include(
      'loads' => 0, 'sourceChanges' => 1, 'pauses' => 0, 'seeks' => 0, 'src' => launch['data-src']
    )
    expect(page.evaluate_script('document.querySelector("video").demoLaunchOrder')).to eq(%w[fullscreen play])
    ratio = page.evaluate_script('document.querySelector("video").demoFullscreenRatio')
    expect(ratio).to be_within(0.01).of(16.0 / 9)
    expect(page.evaluate_script('document.querySelector(".lm-video-stage").inert')).to be false
    find('button[aria-label="動画を閉じる"]').click
    expect(page).not_to have_css('.lm-lesson-dialog')
    expect(page.find(':focus')).to eq(launch)
  end

  it 'toggles available native captions with one CC button' do
    click_button 'レッスンをはじめる'
    stub_video_playback
    within('.lm-lesson-tabs') { click_button 'ベーシックイングリッシュ', exact: true }
    page.execute_script <<~JS
      const video = document.querySelector('video');
      const english = video.addTextTrack('captions', 'English (auto-generated)', 'en-x-autogen');
      english.addCue(new VTTCue(0, 10, 'Hello!'));
      english.mode = 'showing';
    JS
    expect(page).to have_css('.lm-subtitles[aria-pressed="true"]')
    expect(page).not_to have_css('.lm-subtitles select', visible: :all)
    click_button 'CC', exact: true
    expect(page).to have_css('.lm-subtitles[aria-pressed="false"]')
    expect(page.evaluate_script('Array.from(document.querySelector("video").textTracks).every(track => track.mode !== "showing")')).to be true
    click_button 'CC', exact: true
    expect(page).to have_css('.lm-subtitles[aria-pressed="true"]')
    expect(page.evaluate_script('Array.from(document.querySelector("video").textTracks).filter(track => track.mode === "showing").length')).to eq(1)
  end

  it 'loads the actual Vimeo English WebVTT fallback without native HLS caption discovery' do
    click_button 'レッスンをはじめる'
    stub_video_playback
    within('.lm-lesson-tabs') { click_button 'ベーシックイングリッシュ', exact: true }
    click_button 'CC', exact: true
    expect(page).to have_css('video track[src*="subtitles/basic.en"]', visible: :all)
    expect(page).to have_css('video track', visible: :all, wait: 10) { |track|
      page.evaluate_script('arguments[0].readyState === 2 && arguments[0].track.cues && arguments[0].track.cues.length > 0', track)
    }
    expect(page.evaluate_script('document.querySelector("video track").track.mode')).to eq('showing')
    click_button 'CC', exact: true
    expect(page.evaluate_script('document.querySelector("video track").track.mode')).to eq('disabled')
  end

  it 'shows an actual timed caption when the native HLS track has no cues' do
    clip_name = "caption-clock-#{SecureRandom.hex(6)}.mp4"
    clip_path = Rails.public_path.join(clip_name)
    FileUtils.cp(Rails.root.join('spec/fixtures/files/caption-clock.mp4'), clip_path)
    click_button 'レッスンをはじめる'
    page.execute_script <<~JS, "/#{clip_name}"
      const video = document.querySelector('video');
      const button = document.querySelector('.lm-lesson-tabs [data-kind="basic"]');
      video.src = button.dataset.src = arguments[0];
      video.addTextTrack('subtitles', 'English (auto-generated)', 'en-x-autogen');
      document.querySelector('.lm-video-stage').requestFullscreen = () => Promise.resolve();
    JS
    within('.lm-lesson-tabs') { click_button 'ベーシックイングリッシュ', exact: true }
    expect(page).to have_css('button[aria-label="一時停止"]')
    find('button[aria-label="一時停止"]').click
    page.execute_script('document.querySelector("video").currentTime = 1')
    click_button 'CC', exact: true
    expect(page).to have_css('video track', visible: :all, wait: 10) { |track|
      page.evaluate_script('Array.from(arguments[0].track.activeCues || []).some(cue => cue.text.includes("Hello, everyone."))', track)
    }
    expect(page.evaluate_script('Array.from(document.querySelector("video").textTracks).filter(track => track.mode === "showing").length')).to eq(1)
    expect_caption_above_remote
    find('.lm-guide-button').click
    expect(page).to have_css('.lm-guide-panel')
    expect_caption_above_remote
    click_button 'CC', exact: true
    expect(page).to have_css('.lm-subtitles[aria-pressed="false"]')
    click_button 'CC', exact: true
    expect(page).to have_css('video track', visible: :all) { |track|
      page.evaluate_script('Array.from(arguments[0].track.activeCues || []).some(cue => cue.text.includes("Hello, everyone."))', track)
    }
  ensure
    FileUtils.rm_f(clip_path) if clip_path
  end

  it 'hides CC when the video has no caption tracks' do
    click_button 'レッスンをはじめる'
    stub_video_playback
    page.execute_script('document.querySelector("video track").remove()')
    within('.lm-lesson-tabs') { click_button 'ベーシックイングリッシュ', exact: true }
    expect(page).to have_css('.lm-remote')
    expect(page).not_to have_button('CC', exact: true)
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

  it 'keeps lesson navigation in the header and restores focus when each picker closes' do
    click_button 'レッスンをはじめる'
    tabs = find('.lm-lesson-menu .lm-lesson-tabs')
    activity = tabs.find_button('アクティビティ', exact: true)
    activity.click
    within('.lm-picker[open][aria-label="アクティビティを選ぶ"]') do
      expect(page).to have_css('.lm-content-card', count: 3)
      expect(page).not_to have_css('nav', visible: :all)
      find('button[aria-label="閉じる"]').click
    end
    expect(page).not_to have_css('.lm-picker[open]')
    expect(page.find(':focus')).to eq(activity)

    story = tabs.find_button('ストーリータイム', exact: true)
    story.click
    within('.lm-picker[open][aria-label="ストーリーを選ぶ"]') do
      expect(page).to have_css('.lm-content-card', count: 2)
      expect(page).not_to have_css('nav', visible: :all)
    end
    page.driver.browser.action.send_keys(:escape).perform
    expect(page).not_to have_css('.lm-picker[open]')
    expect(page.find(':focus')).to eq(story)
    expect(page).to have_css('.lm-lesson-menu .lm-lesson-tabs')
  end

  it 'switches between the two story videos and their matching captions' do
    stub_video_playback
    within('.lm-sidebar') { click_button 'ストーリータイム', exact: true }
    within('.lm-pages [data-view="stories"]') do
      expect(all('.lm-content-card h2').map(&:text)).to eq(['にげだしたふうせん', 'The Hello Hunt'])
      within(find('.lm-content-card', text: 'The Hello Hunt')) { click_button 'ストーリーをはじめる' }
    end
    expect(page).to have_css('.lm-remote')
    expect(page.evaluate_script('document.querySelector("video").src')).to include('1247526401.m3u8')
    expect(page).to have_css('video track[src*="subtitles/story-2.en"]', visible: :all)
    within('.lm-remote') { click_button '先生用ガイド', exact: true }
    expect(page).to have_css('.lm-guide-panel', text: '地図と赤いすべり台')
    find('button[aria-label="動画を閉じる"]').click

    within('.lm-sidebar') { click_button 'ホーム', exact: true }
    click_button 'レッスンをはじめる'
    within('.lm-lesson-tabs') { click_button 'ストーリータイム', exact: true }
    within('.lm-picker') do
      expect(all('.lm-content-card h2').map(&:text)).to eq(['にげだしたふうせん', 'The Hello Hunt'])
      within(find('.lm-content-card', text: 'にげだしたふうせん')) { click_button 'ストーリーをはじめる' }
    end
    expect(page).to have_css('.lm-remote')
    expect(page.evaluate_script('document.querySelector("video").src')).to include('1225145089.m3u8')
    expect(page).to have_css('video track[src*="subtitles/story.en"]', visible: :all)
  end

  it 'opens Animals and Weather from successive weeks with their own lesson content' do
    stub_video_playback
    [
      [6, 'Animals（動物）', '1239740985', '動物の名前', %w[Cats Dogs Hamsters Rabbits], '折り紙で犬を作ろう', '1239740992', 2],
      [19, 'Weather（天気）', '1247162640', '天気を英語', %w[Sunny Rainy Cloudy Snowy], '色紙を貼って虹を作ろう', '1246964319', 0]
    ].each do |week, title, basic_video, guide, cards, activity, activity_video, downloads|
      click_button '来週', exact: true
      expect(page).to have_css('.lm-week-card', text: "第#{week}週")
      expect(page).to have_css('.lm-week-card', text: title)
      expect(page).to have_css('.lm-content-card', count: 3)
      expect(page).to have_css('a[download]', count: downloads)

      within('.lm-week-card') { click_button '先生用ガイド', exact: true }
      within('.lm-resource-dialog') do
        expect(page).to have_text(guide)
        find('button[aria-label="閉じる"]').click
      end
      click_button 'レッスンをはじめる'
      expect(page).to have_css(".lm-splash[src*='week-#{week}/splash']", wait: 5) { |image|
        page.evaluate_script('arguments[0].naturalWidth > 0', image)
      }
      click_button 'フラッシュカード', exact: true
      within('.lm-flashcards') do
        cards.each do |phrase|
          expect(page).to have_css('.lm-flash-phrase', exact_text: phrase)
          expect(page).to have_css(".lm-flash-artwork[src*='#{phrase.downcase}-']") { |image|
            page.evaluate_script('arguments[0].naturalWidth > 0', image)
          }
          find('button[aria-label="次のカード"]').click
        end
        expect(page).to have_css('.lm-flash-phrase', exact_text: cards.first)
        find('button[aria-label="前のカード"]').click
        expect(page).to have_css('.lm-flash-phrase', exact_text: cards.last)
        page.execute_script <<~JS
          window.lastFlashAudio = null;
          HTMLAudioElement.prototype.play = function() {
            window.lastFlashAudio = this.getAttribute('src');
            return Promise.resolve();
          };
        JS
        find('button[aria-label="音声を聞く"]').click
        expect(page.evaluate_script('window.lastFlashAudio')).to include("week-#{week}/#{cards.last.downcase}-")
        find('button[aria-label="閉じる"]').click
      end

      within('.lm-lesson-tabs') { click_button 'ベーシックイングリッシュ', exact: true }
      expect(page).to have_css('.lm-remote')
      expect(page.evaluate_script('document.querySelector("video").src')).to include("#{basic_video}.m3u8")
      expect(page).to have_css("video track[src*='week-#{week}/basic.en']", visible: :all)
      find('button[aria-label="動画を閉じる"]').click

      within('.lm-lesson-tabs') { click_button 'アクティビティ', exact: true }
      within('.lm-picker') do
        expect(page).to have_css('.lm-content-card', count: 3)
        expect(page).to have_css('a[download]', count: downloads)
        within(find('.lm-content-card', text: activity)) { click_button 'アクティビティをはじめる' }
      end
      expect(page).to have_css('.lm-remote')
      expect(page.evaluate_script('document.querySelector("video").src')).to include("#{activity_video}.m3u8")
      find('button[aria-label="動画を閉じる"]').click
      find('button[aria-label="レッスンを終了"]').click
    end

    click_button '来週', exact: true
    expect(page).to have_css('.lm-upcoming-card', text: 'Coming soon')
    expect(page).not_to have_button('レッスンをはじめる')
    expect(page).not_to have_button('アクティビティをはじめる')
    3.times { click_button '先週', exact: true }
    expect(page).to have_css('.lm-week-card', text: '第1週')
    expect(page).not_to have_css('.lm-upcoming-card')
  end

  it 'uses each activity video and its own teacher guide, chapters, and pause points' do
    stub_video_playback
    [
      ['あいさつの工作', '1225144025', 'はさみ', 'Cut out / 切り抜く', '00:03:58:12', 2, 101 + 22.0 / 24],
      ['なまえをなぞって色ぬり', '1225144026', 'クレヨン', 'Trace your name', '00:04:19:04', 2, 74 + 27.0 / 30],
      ['Helloの点つなぎ', '1225144027', '点つなぎ', 'Find number one', '00:05:51:20', 3, 132]
    ].each_with_index do |(title, video_id, preparation, instruction, ending, chapter_index, chapter_start), index|
      card = find(".lm-pages [data-view='home'] .lm-content-card", text: title)
      within(card) { click_button '先生用ガイド', exact: true }
      within('.lm-resource-dialog') do
        expect(page).to have_text(preparation)
        find('p', text: instruction, visible: :all).scroll_to(:center)
        expect(page).to have_text(instruction)
        find('p', text: ending, visible: :all).scroll_to(:center)
        expect(page).to have_text(ending)
        find('button[aria-label="閉じる"]').click
      end
      within(card) { click_button 'アクティビティをはじめる', exact: true }
      expect(page).to have_css('.lm-remote')
      expect(page.evaluate_script('document.querySelector("video").src')).to include("#{video_id}.m3u8")
      within('.lm-remote') { click_button '先生用ガイド', exact: true }
      expect(page).to have_css('.lm-guide-panel', text: preparation)
      expect(page).to have_css('.lm-guide-heading h2', text: title)
      find('select[data-screen-mirroring-test-target="chapterPicker"]').find_all('option')[chapter_index].select_option
      expect(page).to have_css('.lm-guide-columns', text: instruction) unless index.zero?
      next_time = page.evaluate_script('document.querySelector("video").currentTime')
      expect(next_time).to be_within(0.001).of(chapter_start)
      if index.zero?
        page.execute_script <<~JS
          const video = document.querySelector('video');
          video.currentTime = 137.2;
          video.dispatchEvent(new Event('timeupdate'));
        JS
        expect(page).to have_css('button[aria-label="再生"]')
        expect(page.evaluate_script('document.querySelector("video").currentTime')).to be_within(0.001).of(137 + 1.0 / 24)
        # HLS may settle slightly before the requested pause timestamp.
        page.execute_script('document.querySelector("video").currentTime = 137.01')
        find('button[aria-label="再生"]').click
        page.execute_script <<~JS
          const video = document.querySelector('video');
          video.currentTime = 137.2;
          video.dispatchEvent(new Event('timeupdate'));
          video.currentTime = 141;
          video.dispatchEvent(new Event('timeupdate'));
        JS
        expect(page).to have_css('button[aria-label="一時停止"]')
        page.execute_script <<~JS
          const video = document.querySelector('video');
          video.currentTime = 167.2;
          video.dispatchEvent(new Event('timeupdate'));
        JS
        expect(page).to have_css('button[aria-label="再生"]')
        expect(page.evaluate_script('document.querySelector("video").currentTime')).to eq(167)
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
    expect(page).not_to have_css('.lm-video-stage.fixed')
  end

  private

  def install_lesson_drag_probe
    page.execute_script <<~JS
      window.lessonDragAllowed = (selector, deltaY, fingers = 1) => {
        const target = document.querySelector(selector);
        const touches = y => Array.from({length: fingers}, (_, identifier) =>
          new Touch({identifier, target, clientX: 100 + identifier * 30, clientY: y})
        );
        target.dispatchEvent(new TouchEvent('touchstart', {bubbles: true, touches: touches(200)}));
        const allowed = target.dispatchEvent(new TouchEvent('touchmove', {bubbles: true, cancelable: true, touches: touches(200 + deltaY)}));
        target.dispatchEvent(new TouchEvent('touchend', {bubbles: true, touches: []}));
        return allowed;
      };
    JS
  end

  def expect_caption_above_remote
    # Inspect the browser's rendered cue box, not just TextTrack.mode or activeCues.
    root = page.driver.browser.execute_cdp('DOM.getDocument', depth: -1, pierce: true).fetch('root')
    find_cue = lambda do |node|
      return node if node.fetch('attributes', []).each_slice(2).to_h['pseudo'] == 'cue'

      (node.fetch('children', []) + node.fetch('shadowRoots', [])).each do |child|
        found = find_cue.call(child)
        return found if found
      end
      nil
    end
    cue = find_cue.call(root)
    expect(cue).not_to be_nil
    box = page.driver.browser.execute_cdp('DOM.getBoxModel', backendNodeId: cue.fetch('backendNodeId')).fetch('model')
    bottom = box.fetch('border').each_slice(2).map(&:last).max
    remote_top = page.evaluate_script('document.querySelector(".lm-remote").getBoundingClientRect().top')
    expect(bottom).to be < remote_top
  end

  def stub_video_playback
    # Exercise the real DOM controls with a deterministic media clock, independent
    # of network timing and the browser's support for Vimeo's HLS source.
    page.execute_script <<~JS
      const video = document.querySelector('video');
      let source = video.getAttribute('src') || '';
      const originalGetAttribute = video.getAttribute.bind(video);
      video.removeAttribute('src');
      video.demoLoads = video.demoSourceChanges = video.demoPauses = video.demoSeeks = 0;
      video.demoLaunchOrder = [];
      video.load = () => { video.demoLoads++; };
      video.getAttribute = name => name === 'src' ? source : originalGetAttribute(name);
      let clock = 0;
      Object.defineProperties(video, {
        currentTime: { get: () => clock, set: value => { clock = value; video.demoSeeks++; } },
        src: { get: () => source, set: value => { source = value; clock = 0; video.demoSourceChanges++; } },
        duration: { get: () => 560.125 },
        readyState: { get: () => 1 },
        paused: { get: () => video.demoPaused !== false },
        seeking: { get: () => false }
      });
      video.play = () => {
        video.demoLaunchOrder.push('play');
        video.demoStart = { loads: video.demoLoads, sourceChanges: video.demoSourceChanges, pauses: video.demoPauses, seeks: video.demoSeeks, src: source };
        video.demoPaused = false;
        video.dispatchEvent(new Event('play'));
        return Promise.resolve();
      };
      video.pause = () => {
        video.demoPauses++;
        video.demoPaused = true;
        video.dispatchEvent(new Event('pause'));
      };
      document.querySelector('.lm-video-stage').requestFullscreen = () => {
        const bounds = document.querySelector('.lm-video-stage').getBoundingClientRect();
        video.demoFullscreenRatio = bounds.width / bounds.height;
        video.demoLaunchOrder.push('fullscreen');
        return Promise.resolve();
      };
    JS
  end
end
