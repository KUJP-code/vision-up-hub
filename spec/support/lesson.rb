# frozen_string_literal: true

require 'rails_helper'

RSpec.shared_examples_for 'lesson' do
  let(:lesson) { build(described_class.name.underscore.to_sym) }

  it 'cannot be deleted when associated with a course' do
    course = create(:course)
    lesson.save
    course_lesson = create(:course_lesson, course_id: course.id, lesson_id: lesson.id)
    lesson.course_lessons = [course_lesson]
    expect(lesson.destroy).to be false
  end

  context 'when managing approval' do
    let(:admin) { create(:user, :admin) }
    let(:writer) { create(:user, :writer, organisation: admin.organisation) }
    let(:admin_approval) { [{ id: admin.id, name: admin.name, time: Time.zone.now }] }
    let(:curriculum_approval) { [{ id: writer.id, name: writer.name, time: Time.zone.now }] }

    it 'is approved with both curriculum & admin approval' do
      lesson.admin_approval = admin_approval
      lesson.curriculum_approval = curriculum_approval
      expect(lesson.approved?).to be true
    end

    it 'is approved with only admin approval' do
      lesson.admin_approval = admin_approval
      expect(lesson.approved?).to be true
    end

    it 'is not approved with only curriculum approval' do
      lesson.curriculum_approval = curriculum_approval
      expect(lesson.approved?).to be false
    end

    it 'is not approved with no approval' do
      expect(lesson.approved?).to be false
    end

    it 'does not allow the same user to approve multiple times' do
      lesson.admin_approval = admin_approval
      lesson.save
      lesson.update(admin_approval_id: admin.id, admin_approval_name: admin.name)
      expect(lesson.admin_approval.length).to be 1
    end

    it 'appends new approvals to existing ones if not duplicated' do
      lesson.curriculum_approval = admin_approval
      lesson.save
      lesson.update(curriculum_approval_id: writer.id, curriculum_approval_name: writer.name)
      expect(lesson.curriculum_approval.length).to be 2
    end

    it 'is not released unless approved' do
      lesson.released = true
      expect(lesson.released?).to be false
    end

    it 'cannot be set as released unless approved' do
      lesson.released = true
      lesson.valid?
      expect(lesson.errors[:released]).to be_present
    end
  end

  context 'when mass-reassigning editor' do
    let(:prev_writer) { create(:user, :writer) }
    let(:lessons) { create_list(described_class.name.underscore.to_sym, 3, status: :accepted) }
    let(:new_writer) { create(:user, :writer, organisation: prev_writer.organisation) }

    before do
      prev_writer.assigned_lessons << lessons
      prev_writer.save
    end

    it 'moves all assigned lessons to new editor' do
      Lesson.reassign_editor(prev_writer.id, new_writer.id)
      expect(new_writer.assigned_lessons).to match_array(lessons)
    end

    it 'removes previous editor from lessons' do
      Lesson.reassign_editor(prev_writer.id, new_writer.id)
      expect(prev_writer.assigned_lessons.reload).to be_empty
    end
  end

  context 'when proposing changes' do
    it 'has a valid factory for proposed changes' do
      expect(build(described_class.new.type.underscore.to_sym, :proposal)).to be_valid
    end
  end

  context 'when using replace_with(proposal), the lesson' do
    let(:approval) do
      [{ 'id' => 69, 'name' => 'Approver', 'time' => 'past' }]
    end
    let(:lesson) do
      create(described_class.name.underscore.to_sym,
             admin_approval: approval,
             curriculum_approval: approval)
    end
    let(:proposal) do
      create(described_class.name.underscore.to_sym, :proposal,
             title: 'Proposal Title', goal: 'Proposal Goal',
             internal_notes: "P1\nP2\nP3")
    end

    it 'has its attributes replaced by those of the proposal' do
      lesson.replace_with(proposal)
      lesson_attrs = lesson.attributes
      proposal_attrs = proposal.attributes
      Lesson::NOT_PROPOSABLE.each do |attr|
        lesson_attrs.delete(attr)
        proposal_attrs.delete(attr)
      end
      expect(lesson_attrs).to include(proposal_attrs)
    end

    it 'keeps Lesson::NOT_PROPOSABLE attributes' do
      original_values = lesson.attributes
      lesson.replace_with(proposal)
      Lesson::NOT_PROPOSABLE.each do |attr|
        next if attr == 'updated_at'

        expect(lesson.send(attr)).to eq(original_values[attr])
      end
    end

    it 'keeps its course lessons' do
      course_lesson = create(:course_lesson, lesson:)
      lesson.replace_with(proposal)
      expect(lesson.course_lessons).to contain_exactly(course_lesson)
    end

    it 'keeps its other proposals' do
      extra_proposal = create(
        described_class.name.underscore.to_sym,
        :proposal,
        changed_lesson: lesson
      )
      lesson.replace_with(proposal)
      expect(lesson.proposals).to contain_exactly(extra_proposal)
    end
  end
end
