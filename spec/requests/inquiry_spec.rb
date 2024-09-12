# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Receiving & forwarding inquiry from contact form' do
  it 'can receive data from contact form on vision-up.biz and send email' do
    post inquiries_path,
         params: { inquiry: { email: 'Z2lIc@example.com',
                              name: 'Name', message: 'Message' } }
    queued_mail =
      ActiveJob::Base.queue_adapter.enqueued_jobs
                     .count { |j| j['job_class'] == 'InquiryForwardingJob' }
    expect(queued_mail).to eq 1
  end
end
