# frozen_string_literal: true

require 'rails_helper'

RSpec.shared_examples_for 'lesson' do
  context 'when mass-reassigning editor' do
    let(:prev_writer) { create(:user, :writer) }
    let(:lessons) { create_list(described_class.name.underscore.to_sym, 3) }
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
end
