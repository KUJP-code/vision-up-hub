# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'TriggerableJobs' do
  let(:user) { create(:user, :admin) }

  before do
    sign_in user
  end

  after do
    sign_out user
  end

  describe 'POST /create' do
    it 'queues all guides of a lesson type to be regenerated' do
      create_list(:daily_activity, 3)
      create_list(:stand_show_speak, 2)
      post triggerable_jobs_path, params: { type: 'DailyActivity' }
      expect(ActiveJob::Base.queue_adapter.enqueued_jobs
        .count { |j| j['job_class'] == 'RegenerateGuidesJob' }).to eq(3)
    end
  end
end
