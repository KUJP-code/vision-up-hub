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
      literacy = create(:evening_class, level: :specialist, subtype: :literacy)
      project_session_2 = create(:evening_class, level: :specialist, subtype: :project_session_2)
      relation = Lesson.where(id: [project_session_2.id, literacy.id])

      cards = helper.teacher_lesson_cards('specialist', relation)
      evening_cards = cards.select { |card| card.type == 'EveningClass' }

      expect(evening_cards.map(&:subtype)).to eq(%w[literacy project_session_2])
    end

    it 'does not include legacy specialist resource cards' do
      literacy = create(:evening_class, level: :specialist, subtype: :literacy)

      cards = helper.teacher_lesson_cards('specialist', Lesson.where(id: literacy.id))

      expect(cards.select { |card| card.kind == :resource }.map(&:type)).to be_empty
    end

    it 'does not include the hard-coded keep up conversation time resource card' do
      conversation_time = create(:evening_class, level: :keep_up_one, subtype: :conversation_time)

      keep_up_scope = Lesson.where(id: conversation_time.id).keep_up
      cards = helper.teacher_lesson_cards('keep_up', keep_up_scope)
      resource_types = cards.select { |card| card.kind == :resource }.map(&:type)

      expect(resource_types).not_to include('conversation_time')
      expect(cards.select { |card| card.type == 'EveningClass' }.map(&:subtype)).to include('conversation_time')
    end
  end

  describe '#teacher_lesson_card_title' do
    it 'uses the subtype label for evening class subtype cards' do
      expect(helper.teacher_lesson_card_title('EveningClass', level: 'specialist', subtype: 'discussion'))
        .to eq(I18n.t('lessons.subtypes.discussion'))
    end
  end
end
