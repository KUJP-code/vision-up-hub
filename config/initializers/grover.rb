Grover.configure do |config|
  config.options = {
    # 30s timeouts happen so make it 120
    navigation_timeout: 120_000,

    launch_args: [
      '--no-sandbox',
      '--disable-dev-shm-usage'
    ]
  }
end
