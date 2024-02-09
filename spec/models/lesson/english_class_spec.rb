# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EnglishClass do
  it 'has a valid factory' do
    expect(build(:english_class)).to be_valid
  end

  it_behaves_like 'lesson'

  it 'sets topic from lesson_topic, term and unit' do
    english_class = build(:english_class, lesson_topic: 'Topic', term: 1, unit: 1)
    english_class.save
    expect(english_class.topic).to eq('Term 1 Unit 1 - Topic')
  end
end
