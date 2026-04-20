# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TeacherLessonHelper do
  describe '#teacher_lesson_cards' do
    let(:user) { build_stubbed(:user) }

    before do
      allow(helper).to receive(:current_user).and_return(user)
      allow(Flipper).to receive(:enabled?).and_return(true)
    end

    it 'renders specialist evening class cards in the configured subtype order' do
      project_session_2 = create(:evening_class, level: :specialist, subtype: :project_session_2)
      special_lesson = create(:evening_class, level: :specialist, subtype: :special_lesson)
      relation = Lesson.where(id: [special_lesson.id, project_session_2.id])

      cards = helper.teacher_lesson_cards('specialist', relation)
      evening_cards = cards.select { |card| card.type == 'EveningClass' }

      expect(evening_cards.map(&:subtype)).to eq(%w[project_session_2 special_lesson])
    end

    it 'ignores legacy specialist evening lesson subtypes' do
      literacy = create(:evening_class, level: :specialist, subtype: :literacy)

      cards = helper.teacher_lesson_cards('specialist', Lesson.where(id: literacy.id))

      expect(cards.select { |card| card.type == 'EveningClass' }).to be_empty
    end

    it 'includes specialist literacy and discussion resource cards around evening class cards' do
      project_session_1 = create(:evening_class, level: :specialist, subtype: :project_session_1)

      cards = helper.teacher_lesson_cards('specialist', Lesson.where(id: project_session_1.id))

      expect(cards.map { |card| [card.kind, card.type, card.subtype] }).to eq([
        [:resource, 'sp_literacy', nil],
        [:lesson, 'EveningClass', 'project_session_1'],
        [:resource, 'sp_discussion', nil]
      ])
    end

    it 'does not include the hard-coded keep up conversation time resource card' do
      conversation_time = create(:evening_class, level: :keep_up_one, subtype: :conversation_time)

      keep_up_scope = Lesson.where(id: conversation_time.id).keep_up
      cards = helper.teacher_lesson_cards('keep_up', keep_up_scope)
      resource_types = cards.select { |card| card.kind == :resource }.map(&:type)

      expect(resource_types).not_to include('conversation_time')
      expect(cards.select { |card| card.type == 'EveningClass' }.map(&:subtype)).to include('conversation_time')
    end

    it 'keeps snack as the first keep up resource before book activity when afterschool extras are off' do
      allow(Flipper).to receive(:enabled?).with(:afterschool_extras, user).and_return(false)
      conversation_time = create(:evening_class, level: :keep_up_one, subtype: :conversation_time)

      keep_up_scope = Lesson.where(id: conversation_time.id).keep_up
      cards = helper.teacher_lesson_cards('keep_up', keep_up_scope)

      expect(cards.select { |card| card.kind == :resource }.map(&:type)).to eq(%w[snack book_activity lesson_review])
    end
  end

  describe '#teacher_lesson_card_title' do
    it 'uses the subtype label for evening class subtype cards' do
      expect(helper.teacher_lesson_card_title('EveningClass', level: 'specialist', subtype: 'project_session_2'))
        .to eq(I18n.t('lessons.subtypes.project_session_2'))
    end

    it 'uses the teacher-facing label for specialist literacy resource cards' do
      expect(helper.teacher_lesson_card_title('sp_literacy', level: 'specialist'))
        .to eq(I18n.t('teacher_resources.index.sp_literacy'))
    end

    it 'uses the teacher-facing label for specialist discussion resource cards' do
      expect(helper.teacher_lesson_card_title('sp_discussion', level: 'specialist'))
        .to eq(I18n.t('teacher_resources.index.sp_discussion'))
    end
  end
end
