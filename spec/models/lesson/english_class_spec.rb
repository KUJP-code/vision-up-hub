# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EnglishClass do
  it_behaves_like 'lesson'

  it 'has a valid factory' do
    expect(build(:english_class)).to be_valid
  end

  context 'when working with topic' do
    let(:english_class) { create(:english_class, lesson_topic: 'Topic', term: '5', unit: '4') }

    it 'sets topic from lesson_topic, term and unit' do
      expect(english_class.topic).to eq('Term 5 Unit 4 - Topic')
    end

    it 'does not reset topic when released or approved' do
      og_topic = english_class.topic
      english_class.update(admin_approval_id: 1, admin_approval_name: 'Admin',
                           topic: nil, term: nil, unit: nil)
      english_class.update(released: true)
      expect(english_class.reload.topic).to eq(og_topic)
    end

    it 'grabs the lesson topic from main topic col' do
      expect(english_class.lesson_topic).to eq('Topic')
    end

    it 'grabs the term from main topic col' do
      expect(english_class.term).to eq('5')
    end

    it 'grabs the unit from main topic col' do
      expect(english_class.unit).to eq('4')
    end

    it 'still grabs the unit if there is a number in the lesson topic' do
      english_class.update(lesson_topic: 'W2 Topic')
      expect(english_class.unit).to eq('4')
    end
  end

  context 'when generating PDF guide' do
    it 'does not generate a PDF' do
      pdf = build(:english_class).attach_guide
      expect(pdf).to be_nil
    end
  end
end
