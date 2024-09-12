# frozen_string_literal: true

require 'rails_helper'

RSpec.describe InquiryForwardingJob do
  include ActiveJob::TestHelper

  after do
    clear_enqueued_jobs
  end

  it 'fails the job if inquiry is invalid' do
    expect { described_class.perform_now({ email: '' }) }
      .to raise_error(ActiveModel::ValidationError)
  end
end
