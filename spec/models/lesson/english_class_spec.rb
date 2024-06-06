# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EnglishClass do
  it_behaves_like 'lesson'

  it 'has a valid factory' do
    expect(build(:english_class)).to be_valid
  end

  it 'sets topic from lesson_topic, term and unit' do
    english_class = build(:english_class, lesson_topic: 'Topic', term: 1, unit: 1)
    english_class.save
    expect(english_class.topic).to eq('Term 1 Unit 1 - Topic')
  end

  context 'when generating PDF guide' do
    it 'does not generate a PDF' do
      pdf = build(:english_class).attach_guide
      expect(pdf).to be_nil
    end
  end
end
