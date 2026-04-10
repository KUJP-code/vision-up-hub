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

    it 'does not change phonics resources when proposing phonics lesson edits' do
      course = create(:course)
      phonics_class = create(:phonics_class, status: :accepted)
      blob = ActiveStorage::Blob.create_and_upload!(
        io: StringIO.new('phonics resource'),
        filename: 'phonics-resource.pdf',
        content_type: 'application/pdf'
      )
      phonics_class.phonics_resources.create!(blob:, course:, week: 3)
      allow_any_instance_of(Lesson).to receive(:attach_guide).and_return(nil)

      patch phonics_class_path(id: phonics_class.id),
            params: {
              phonics_class: {
                title: 'Updated Title',
                goal: phonics_class.goal,
                level: phonics_class.level,
                add_difficulty: phonics_class.add_difficulty,
                extra_fun: phonics_class.extra_fun,
                instructions: phonics_class.instructions,
                intro: phonics_class.intro,
                review: phonics_class.review,
                materials: phonics_class.materials,
                phonics_resources_attributes: {
                  '0' => {
                    blob_id: blob.id,
                    course_id: course.id,
                    week: 8
                  }
                }
              }
            }

      expect(phonics_class.reload.phonics_resources.pluck(:week)).to eq([3])
    end
  end

  context 'when accepting a proposal' do
    let(:user) { create(:user, :admin) }
    let(:lesson) { create(:daily_activity, creator: user, assigned_editor: user) }
    let(:proposal) do
      create(:daily_activity, :proposal, changed_lesson: lesson, creator: user, assigned_editor: user)
    end

    it 'regenerates the accepted lesson guide' do
      expect(lesson.guide).not_to be_attached

      patch proposal_path(id: proposal.id),
            params: { proposal: { status: 'accepted' } }

      expect(response).to redirect_to(lesson_url(id: lesson.id))
      expect(lesson.reload.guide).to be_attached
    end

    it 'does not make the accepted proposal show up as a normal lesson' do
      patch proposal_path(id: proposal.id),
            params: { proposal: { status: 'accepted' } }

      expect(Lesson.canonical.accepted).to include(lesson)
      expect(Lesson.canonical.accepted).not_to include(proposal.reload)
    end
  end
end
