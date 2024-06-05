# frozen_string_literal: true

require 'rails_helper'

RSpec.describe KindyPhonics do
  it_behaves_like 'lesson'

  it 'has a valid factory' do
    expect(build(:kindy_phonics)).to be_valid
  end

  it 'ensures level is kindy' do
    kindy_phonics = create(:kindy_phonics, level: nil)
    expect(kindy_phonics.level).to eq('kindy')
  end

  it 'sets topic from lesson_topic, term and unit' do
    kindy_phonics = build(:kindy_phonics, lesson_topic: 'Topic', term: 1, unit: 1)
    kindy_phonics.save
    expect(kindy_phonics.topic).to eq('Term 1 Unit 1 - Topic')
  end

  context 'when generating PDF guide' do
    it 'does not generate a PDF' do
      pdf = build(:kindy_phonics).attach_guide
      expect(pdf).to be_nil
    end
  end
end
