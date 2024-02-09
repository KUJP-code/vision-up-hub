# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Lesson do
  let(:lesson) { create(:stand_show_speak) }
  let(:approval_details) { [{ id: user.id, name: user.name, time: Time.zone.now }] }
  let(:stored_approval) do
    [{ 'id' => user.id.to_s,
       'name' => user.name,
       'time' => approval_details.first[:time].to_s }]
  end

  before do
    sign_in user
  end

  after do
    sign_out user
  end

  context 'when admin' do
    let(:user) { create(:user, :admin) }

    it 'can directly edit lesson attributes' do
      patch stand_show_speak_path(lesson), params: { stand_show_speak: { title: 'New Title' } }
      expect(lesson.reload.title).to eq 'New Title'
    end

    it 'can alter admin approval' do
      patch stand_show_speak_path(lesson),
            params: { stand_show_speak: { admin_approval: approval_details } }
      expect(lesson.reload.admin_approval).to eq(stored_approval)
    end

    it 'can alter curriculum approval' do
      patch stand_show_speak_path(lesson),
            params: { stand_show_speak: { curriculum_approval: approval_details } }
      expect(lesson.reload.curriculum_approval).to eq(stored_approval)
    end
  end

  context 'when writer' do
    let(:user) { create(:user, :writer) }

    it 'cannot directly edit lesson attributes' do
      patch stand_show_speak_path(lesson), params: { stand_show_speak: { title: 'New Title' } }
      expect(lesson.reload.title).not_to eq 'New Title'
    end

    it 'cannot alter admin approval' do
      patch stand_show_speak_path(lesson),
            params: { stand_show_speak: { admin_approval: approval_details } }
      expect(lesson.reload.admin_approval).to eq([])
    end

    it 'can alter curriculum approval' do
      patch stand_show_speak_path(lesson),
            params: { stand_show_speak: { curriculum_approval: approval_details } }
      expect(lesson.reload.curriculum_approval).to eq(stored_approval)
    end

    it 'can alter internal notes' do
      patch stand_show_speak_path(lesson),
            params: { stand_show_speak: { internal_notes: "I'm a note!" } }
      expect(lesson.reload.internal_notes).to eq "I'm a note!"
    end
  end
end
