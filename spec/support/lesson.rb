# frozen_string_literal: true

require 'rails_helper'

RSpec.shared_examples_for 'lesson' do
  context 'when managing approval' do
    let(:lesson) { build(described_class.name.underscore.to_sym) }
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
end
