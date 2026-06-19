# frozen_string_literal: true

require 'rails_helper'

RSpec.describe InquiryForwardingJob do
  include ActiveJob::TestHelper

  after do
    clear_enqueued_jobs
    ActionMailer::Base.deliveries.clear
  end

  it 'fails the job if inquiry is invalid' do
    expect { described_class.perform_now({ email: '' }) }
      .to raise_error(ActiveModel::ValidationError)
  end

  it 'sends an internal notification and customer confirmation' do
    inquiry_params = attributes_for(:inquiry, email: 'customer@example.com')

    expect { described_class.perform_now(inquiry_params) }
      .to change { ActionMailer::Base.deliveries.count }.by(2)

    expect(ActionMailer::Base.deliveries.map(&:subject)).to contain_exactly(
      'New VisionUP Inquiry',
      '【VisionUP】お問い合わせありがとうございます'
    )
  end
end
