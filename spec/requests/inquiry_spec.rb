# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Receiving & forwarding inquiry from contact form' do
  let(:recaptcha_result) do
    RecaptchaVerifier::Result.new(success: true, error_codes: [])
  end

  before do
    allow(RecaptchaVerifier).to receive(:verify).and_return(recaptcha_result)
  end

  def inquiry_jobs_count
    ActiveJob::Base.queue_adapter.enqueued_jobs
                   .count { |j| j['job_class'] == 'InquiryForwardingJob' }
  end

  it 'enqueues job for the normal contact form' do
    expect do
      post inquiries_path,
           params: {
             inquiry: {
               email: 'normal@example.com',
               name: 'Name',
               message: 'Message'
             }
           }
    end.to change { inquiry_jobs_count }.by(1)
  end

  it 'enqueues job for the join inquiry form without message' do
    expect do
      post inquiries_path,
           params: {
             inquiry: {
               email: 'join@example.com',
               name: 'Join Name',
               category: 'join',
               phone: '0312345678',
               postal_code: '1234567',
               address_pref: '東京都',
               address_city: '千代田区',
               address_line: '1-1-1',
               gender: 'male',
               age: 40
             }
           }
    end.to change { inquiry_jobs_count }.by(1)
  end

  it 'rejects the inquiry when reCAPTCHA verification fails' do
    allow(RecaptchaVerifier).to receive(:verify).and_return(
      RecaptchaVerifier::Result.new(success: false, error_codes: ['timeout-or-duplicate'])
    )

    expect do
      post inquiries_path,
           params: {
             recaptcha_token: 'bad-token',
             inquiry: {
               email: 'normal@example.com',
               name: 'Name',
               message: 'Message'
             }
           }
    end.not_to change { inquiry_jobs_count }

    expect(response).to redirect_to('https://www.vision-up.biz/contact')
  end
end
