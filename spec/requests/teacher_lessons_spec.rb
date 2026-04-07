# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Teacher lessons', type: :request do
  describe 'GET /teacher_lessons/:id for keep up evening classes' do
    let(:date) { Time.zone.today.beginning_of_week.to_date }
    let(:organisation) { create(:organisation, name: 'KidsUP') }
    let(:admin) { create(:user, :admin, organisation:) }
    let(:teacher) { create(:user, :teacher, organisation:) }
    let(:course) { create(:course) }
    let!(:plan) { create(:plan, organisation:, course:, start: date.beginning_of_week) }
    let!(:keep_up_one_lesson) do
      create(
        :evening_class,
        level: :keep_up_one,
        subtype: :conversation_time,
        title: 'Keep Up 1 Conversation Time',
        goal: 'Practice speaking with guided conversation prompts.'
      )
    end
    let!(:keep_up_two_lesson) do
      create(:evening_class, level: :keep_up_two, subtype: :conversation_time, title: 'Keep Up 2 Conversation Time')
    end

    before do
      sign_in admin
      create(:course_lesson, course:, lesson: keep_up_one_lesson, week: 1, day: :monday)
      create(:course_lesson, course:, lesson: keep_up_two_lesson, week: 1, day: :monday)
      allow(Flipper).to receive(:enabled?).with(:keep_up, teacher).and_return(true)
      allow(Flipper).to receive(:enabled?).with(:kindy, teacher).and_return(false)
      allow(Flipper).to receive(:enabled?).with(:elementary, teacher).and_return(false)
      allow(Flipper).to receive(:enabled?).with(:specialist, teacher).and_return(false)
    end

    it 'uses the first keep up lesson and does not render tabs for keep up one/two variants' do
      get teacher_lesson_path(
        0,
        teacher_id: teacher.id,
        date: date,
        level: 'keep_up',
        type: 'EveningClass',
        subtype: 'conversation_time'
      )

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Keep Up 1 Conversation Time')
      expect(response.body).not_to include('Keep Up 2 Conversation Time')
      expect(response.body).to include('Practice speaking with guided conversation prompts.')
      expect(response.body).not_to include('Evening Class')
      expect(response.body).not_to include('class="tab ')
    end
  end
end
