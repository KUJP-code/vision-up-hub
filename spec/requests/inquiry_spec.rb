# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Receiving & forwarding inquiry from contact form' do
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
end
