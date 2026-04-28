# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RecaptchaVerifier do
  around do |example|
    original_secret = ENV.fetch('RECAPTCHA_SECRET_KEY', nil)
    ENV['RECAPTCHA_SECRET_KEY'] = 'secret'
    example.run
  ensure
    ENV['RECAPTCHA_SECRET_KEY'] = original_secret
  end

  it 'passes for a successful inquiry_submit response above the score threshold' do
    stub_siteverify(
      success: true,
      action: 'inquiry_submit',
      score: 0.9,
      'error-codes': []
    )

    result = described_class.verify(token: 'token')

    expect(result).to be_success
    expect(result.score).to eq(0.9)
  end

  it 'fails when Google returns a low score' do
    stub_siteverify(success: true, action: 'inquiry_submit', score: 0.3)

    expect(described_class.verify(token: 'token')).not_to be_success
  end

  it 'fails when the action does not match the inquiry form action' do
    stub_siteverify(success: true, action: 'other_action', score: 0.9)

    expect(described_class.verify(token: 'token')).not_to be_success
  end

  def stub_siteverify(response)
    http_response = instance_double(Net::HTTPResponse, body: response.to_json)
    allow(Net::HTTP).to receive(:post_form).and_return(http_response)
  end
end
