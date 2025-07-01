ENV['PUPPETEER_DISABLE_SHUTDOWN_HANDLERS'] = '1'
Grover.configure do |config|
  config.options = {
    launch_args: ['--no-sandbox', '--disable-dev-shm-usage']
  }
end
