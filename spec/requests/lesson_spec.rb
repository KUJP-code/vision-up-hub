# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Lesson do
  let(:lesson) { create(:stand_show_speak) }
  let(:pdf) { Rails.root.join('spec/example_lesson.pdf') }

  before do
    sign_in user
  end

  after do
    sign_out user
  end

  context 'when admin' do
    let(:user) { create(:user, :admin) }

    it 'can alter admin approval' do
      patch stand_show_speak_path(lesson),
            params: { stand_show_speak:
                      { admin_approval_id: user.id,
                        admin_approval_name: user.name } }
      stored_approval = lesson.reload.admin_approval.first
      expect(stored_approval['id']).to eq user.id.to_s
    end

    it 'can alter curriculum approval' do
      patch stand_show_speak_path(lesson),
            params: { stand_show_speak:
                      { curriculum_approval_id: user.id,
                        curriculum_approval_name: user.name } }
      stored_approval = lesson.reload.curriculum_approval.first
      expect(stored_approval['id']).to eq user.id.to_s
    end
  end

  context 'when writer' do
    let(:user) { create(:user, :writer) }
    let(:approval_details) do
      { curriculum_approval_id: user.id, curriculum_approved_name: user.name }
    end

    it 'cannot alter admin approval' do
      patch stand_show_speak_path(lesson),
            params: { stand_show_speak:
                      { admin_approval_id: user.id, admin_approved_name: user.name },
                      commit: I18n.t('approve') }
      expect(lesson.reload.admin_approval).to eq([])
    end

    it 'can alter curriculum approval' do
      patch stand_show_speak_path(lesson),
            params: { stand_show_speak:
                      { curriculum_approval_id: user.id,
                        curriculum_approval_name: user.name },
                      commit: I18n.t('approve') }
      stored_approval = lesson.reload.curriculum_approval.first
      expect(stored_approval['id']).to eq user.id.to_s
    end

    it 'can alter internal notes' do
      patch stand_show_speak_path(lesson),
            params: { stand_show_speak: { internal_notes: "I'm a note!" },
                      commit: I18n.t('update_notes') }
      expect(lesson.reload.internal_notes).to eq "I'm a note!"
    end
  end

  context 'with seasonal activities' do
    let(:user) { create(:user, :admin) }

    def pdf_upload
      Rack::Test::UploadedFile.new(pdf, 'application/pdf')
    end

    it 'can add and display galaxy english class sheets' do
      post seasonal_activities_path,
           params: {
             seasonal_activity: {
               type: 'SeasonalActivity',
               title: 'Summer School',
               goal: 'Seasonal fun',
               activity_guide: pdf_upload,
               scrapbook: pdf_upload,
               kindy_english_class: pdf_upload,
               ele_english_class: pdf_upload,
               galaxy_low_english_class: pdf_upload,
               galaxy_high_english_class: pdf_upload,
               galaxy_questions_english_class: pdf_upload
             }
           }

      seasonal = SeasonalActivity.find_by!(title: 'Summer School')
      expect(seasonal.galaxy_low_english_class).to be_attached
      expect(seasonal.galaxy_high_english_class).to be_attached
      expect(seasonal.galaxy_questions_english_class).to be_attached

      get lesson_path(seasonal)

      expect(response.body).to include('Kindy English')
      expect(response.body).to include('English')
      expect(response.body).to include('Galaxy')
      expect(response.body).to include('>Low<')
      expect(response.body).to include('>High<')
      expect(response.body).to include('>Questions<')
      expect(response.body).not_to include('Remove example_lesson.pdf from this lesson?')

      get edit_lesson_path(seasonal)

      expect(response.body).to include('example_lesson.pdf')
      expect(response.body).not_to include('Remove example_lesson.pdf from this lesson?')
    end
  end
end
