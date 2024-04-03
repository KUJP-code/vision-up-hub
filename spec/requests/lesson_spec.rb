# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Lesson do
  let(:lesson) { create(:stand_show_speak) }

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
end
