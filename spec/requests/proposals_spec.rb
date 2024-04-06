# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Proposals' do
  let(:lesson) { create(:stand_show_speak) }

  before do
    sign_in user
  end

  after do
    sign_out user
  end

  context 'when admin' do
    let(:user) { create(:user, :admin) }

    it 'can directly edit lesson attributes' do
      patch stand_show_speak_path(lesson),
            params: { stand_show_speak: { title: 'New Title', goal: 'New Goal' } }
      expect(lesson.reload.title).to eq 'New Title'
    end
  end

  context 'when writer' do
    let(:user) { create(:user, :writer) }

    it 'cannot directly edit lesson attributes' do
      patch stand_show_speak_path(lesson),
            params: { stand_show_speak: { title: 'New Title', goal: 'New Goal' } }
      expect(lesson.reload.title).not_to eq 'New Title'
    end

    it 'can edit proposal without creating a new proposal' do
      proposal = create(:stand_show_speak, :proposal, changed_lesson: lesson, title: 'New Title')
      expect(lesson.proposals.count).to eq 1
      patch stand_show_speak_path(id: proposal.id),
            params: { stand_show_speak: { title: 'Newer Title' } }
      expect(lesson.proposals.count).to eq 1
      expect(proposal.reload.title).to eq 'Newer Title'
    end

    it 'automatically updates proposal status to proposed when edited' do
      proposal = create(:stand_show_speak, :proposal, status: :changes_needed)
      patch stand_show_speak_path(id: proposal.id),
            params: { stand_show_speak: { title: 'Fixed Title' } }
      expect(proposal.reload.status).to eq 'proposed'
    end
  end
end
