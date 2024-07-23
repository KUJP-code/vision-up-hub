# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EnglishClass do
  it_behaves_like 'lesson'

  it 'has a valid factory' do
    expect(build(:english_class)).to be_valid
  end

  context 'when setting topic' do
    it 'sets topic from lesson_topic, term and unit' do
      english_class = build(:english_class, lesson_topic: 'Topic', term: 1, unit: 1)
      english_class.save
      expect(english_class.topic).to eq('Term 1 Unit 1 - Topic')
    end

    it 'does not reset topic when released or approved' do
      english_class = create(:english_class, lesson_topic: 'Topic',
                                             term: '1', unit: '1')
      og_topic = english_class.topic
      english_class.update(admin_approval_id: 1, admin_approval_name: 'Admin',
                           topic: nil, term: nil, unit: nil)
      english_class.update(released: true)
      expect(english_class.reload.topic).to eq(og_topic)
    end
  end

  context 'when generating PDF guide' do
    it 'does not generate a PDF' do
      pdf = build(:english_class).attach_guide
      expect(pdf).to be_nil
    end
  end
end
