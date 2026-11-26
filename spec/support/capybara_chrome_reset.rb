# frozen_string_literal: true

# Capybara 3.40 resets Chrome between tests with the DevTools call
# `Storage.clearDataForOrigin(origin: '*')`. Newer Chrome (150+) no longer
# accepts '*' as an origin and fails every JS system spec in cleanup with
# "invalid argument: * is not a valid URL". Clear cookies for every origin,
# and local storage for the test server's origin, instead.
#
# Remove once Capybara ships a fix (check chrome_driver.rb#reset!).
module CapybaraChromeResetFix
  def execute_cdp(cmd, **args)
    return super unless cmd == 'Storage.clearDataForOrigin' && args[:origin] == '*'

    super('Network.clearBrowserCookies')

    types = args[:storageTypes].to_s.split(',') - ['cookies']
    origin = Capybara.current_session.server&.base_url
    super(cmd, origin:, storageTypes: types.join(',')) if types.any? && origin
  end
end

require 'capybara/selenium/driver'
Capybara::Selenium::Driver::ChromeDriver.prepend(CapybaraChromeResetFix)
