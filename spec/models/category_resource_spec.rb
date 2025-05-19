# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CategoryResource do
  let(:category_resource) { build(:category_resource) }

  it 'has a valid factory' do
    expect(category_resource).to be_valid
  end

  it 'cannot be deleted when associated with a course' do
    course = create(:course)
    category_resource.save
    course.category_resources << category_resource
    expect(category_resource.destroy).to be false
  end

  context 'when resource for a Story and Reading class' do
    before do
      category_resource.lesson_category = :story_and_reading
    end

    it 'cannot have phonics set as a resource category' do
      category_resource.resource_category = :phonics_sets
      expect(category_resource).not_to be_valid
    end

    it 'cannot have word family as a resource category' do
      category_resource.resource_category = :word_families
      expect(category_resource).not_to be_valid
    end

    it 'cannot have sight words as a resource category' do
      category_resource.resource_category = :sight_words
      expect(category_resource).not_to be_valid
    end

    it 'cannot have activities as a resource category' do
      category_resource.resource_category = :activities
      expect(category_resource).not_to be_valid
    end

    it 'can have a worksheet as a resource category' do
      category_resource.resource_category = :worksheets
      expect(category_resource).to be_valid
    end

    it 'can have slides as a resource category' do
      category_resource.resource_category = :slides
      expect(category_resource).to be_valid
    end
  end

  context 'when resource for a sensory play' do
    before do
      category_resource.lesson_category = :sensory_play
    end

    it 'cannot have phonics set as a resource category' do
      category_resource.resource_category = :phonics_sets
      expect(category_resource).not_to be_valid
    end

    it 'cannot have word family as a resource category' do
      category_resource.resource_category = :word_families
      expect(category_resource).not_to be_valid
    end

    it 'cannot have sight words as a resource category' do
      category_resource.resource_category = :sight_words
      expect(category_resource).not_to be_valid
    end

    it 'cannot have activities as a resource category' do
      category_resource.resource_category = :activities
      expect(category_resource).not_to be_valid
    end

    it 'can have a worksheet as a resource category' do
      category_resource.resource_category = :worksheets
      expect(category_resource).to be_valid
    end

    it 'can have slides as a resource category' do
      category_resource.resource_category = :slides
      expect(category_resource).to be_valid
    end
  end

  context 'when resource for a get up and go class' do
    before do
      category_resource.lesson_category = :get_up_and_go
    end

    it 'cannot have phonics set as a resource category' do
      category_resource.resource_category = :phonics_sets
      expect(category_resource).not_to be_valid
    end

    it 'cannot have word family as a resource category' do
      category_resource.resource_category = :word_families
      expect(category_resource).not_to be_valid
    end

    it 'cannot have sight words as a resource category' do
      category_resource.resource_category = :sight_words
      expect(category_resource).not_to be_valid
    end

    it 'can have activities as a resource category' do
      category_resource.resource_category = :activities
      expect(category_resource).to be_valid
    end

    it 'can have a worksheet as a resource category' do
      category_resource.resource_category = :worksheets
      expect(category_resource).to be_valid
    end

    it 'can have slides as a resource category' do
      category_resource.resource_category = :slides
      expect(category_resource).to be_valid
    end
  end

  context 'when resource for a friendship class' do
    before do
      category_resource.lesson_category = :friendship_time
    end

    it 'cannot have phonics set as a resource category' do
      category_resource.resource_category = :phonics_sets
      expect(category_resource).not_to be_valid
    end

    it 'cannot have word family as a resource category' do
      category_resource.resource_category = :word_families
      expect(category_resource).not_to be_valid
    end

    it 'cannot have sight words as a resource category' do
      category_resource.resource_category = :sight_words
      expect(category_resource).not_to be_valid
    end

    it 'cannot have activities as a resource category' do
      category_resource.resource_category = :activities
      expect(category_resource).not_to be_valid
    end

    it 'can have a worksheet as a resource category' do
      category_resource.resource_category = :worksheets
      expect(category_resource).to be_valid
    end

    it 'can have slides as a resource category' do
      category_resource.resource_category = :slides
      expect(category_resource).to be_valid
    end
  end

  context 'when resource for phonics class' do
    before do
      category_resource.lesson_category = :phonics_class
    end

    it 'can have phonics set as a resource category' do
      category_resource.resource_category = :phonics_sets
      expect(category_resource).to be_valid
    end

    it 'can have word family as a resource category' do
      category_resource.resource_category = :word_families
      expect(category_resource).to be_valid
    end

    it 'can have sight words as a resource category' do
      category_resource.resource_category = :sight_words
      expect(category_resource).to be_valid
    end

    it 'cannot have worksheets as a resource category' do
      category_resource.resource_category = :worksheets
      expect(category_resource).not_to be_valid
    end

    it 'cannot have slides as a resource category' do
      category_resource.resource_category = :slides
      expect(category_resource).not_to be_valid
    end

    it 'cannot have activities as a resource category' do
      category_resource.resource_category = :activities
      expect(category_resource).not_to be_valid
    end
  end

  context 'when resource for brush up' do
    before do
      category_resource.lesson_category = :brush_up
    end

    it 'cannnot have phonics set as a resource category' do
      category_resource.resource_category = :phonics_sets
      expect(category_resource).not_to be_valid
    end

    it 'cannot have word family as a resource category' do
      category_resource.resource_category = :word_families
      expect(category_resource).not_to be_valid
    end

    it 'cannot have sight words as a resource category' do
      category_resource.resource_category = :sight_words
      expect(category_resource).not_to be_valid
    end

    it 'can have worksheets as a resource category' do
      category_resource.resource_category = :worksheets
      expect(category_resource).to be_valid
    end

    it 'cannot have slides as a resource category' do
      category_resource.resource_category = :slides
      expect(category_resource).not_to be_valid
    end

    it 'cannot have activities as a resource category' do
      category_resource.resource_category = :activities
      expect(category_resource).not_to be_valid
    end
  end

  context 'when resource for snack' do
    before do
      category_resource.lesson_category = :snack
    end

    it 'cannot have phonics set as a resource category' do
      category_resource.resource_category = :phonics_sets
      expect(category_resource).not_to be_valid
    end

    it 'cannot have word family as a resource category' do
      category_resource.resource_category = :word_families
      expect(category_resource).not_to be_valid
    end

    it 'cannot have sight words as a resource category' do
      category_resource.resource_category = :sight_words
      expect(category_resource).not_to be_valid
    end

    it 'can have worksheets as a resource category' do
      category_resource.resource_category = :worksheets
      expect(category_resource).to be_valid
    end

    it 'can have slides as a resource category' do
      category_resource.resource_category = :slides
      expect(category_resource).to be_valid
    end

    it 'cannot have activities as a resource category' do
      category_resource.resource_category = :activities
      expect(category_resource).not_to be_valid
    end
  end

  context 'when resource for get up & go' do
    before do
      category_resource.lesson_category = :get_up_and_go
    end

    it 'cannot have phonics set as a resource category' do
      category_resource.resource_category = :phonics_sets
      expect(category_resource).not_to be_valid
    end

    it 'cannot have word family as a resource category' do
      category_resource.resource_category = :word_families
      expect(category_resource).not_to be_valid
    end

    it 'cannot have sight words as a resource category' do
      category_resource.resource_category = :sight_words
      expect(category_resource).not_to be_valid
    end

    it 'can have worksheets as a resource category' do
      category_resource.resource_category = :worksheets
      expect(category_resource).to be_valid
    end

    it 'can have slides as a resource category' do
      category_resource.resource_category = :slides
      expect(category_resource).to be_valid
    end

    it 'cannot have activities as a resource category' do
      category_resource.resource_category = :activities
      expect(category_resource).to be_valid
    end
  end

  context 'when resource for daily gathering' do
    before do
      category_resource.lesson_category = :daily_gathering
    end

    it 'cannot have phonics set as a resource category' do
      category_resource.resource_category = :phonics_sets
      expect(category_resource).not_to be_valid
    end

    it 'cannot have word family as a resource category' do
      category_resource.resource_category = :word_families
      expect(category_resource).not_to be_valid
    end

    it 'cannot have sight words as a resource category' do
      category_resource.resource_category = :sight_words
      expect(category_resource).not_to be_valid
    end

    it 'can have worksheets as a resource category' do
      category_resource.resource_category = :worksheets
      expect(category_resource).to be_valid
    end

    it 'can have slides as a resource category' do
      category_resource.resource_category = :slides
      expect(category_resource).to be_valid
    end

    it 'cannot have activities as a resource category' do
      category_resource.resource_category = :activities
      expect(category_resource).not_to be_valid
    end
  end

  context 'when resource for evening class' do
    before do
      category_resource.lesson_category = :evening_class
    end

    it 'can have worksheets as a resource category' do
      category_resource.resource_category = :worksheets
      expect(category_resource).to be_valid
    end

    it 'can have activities as a resource category' do
      category_resource.resource_category = :activities
      expect(category_resource).to be_valid
    end

    it 'cannot have word families as a resource category' do
      category_resource.resource_category = :word_families
      expect(category_resource).not_to be_valid
    end

    it 'cannot have phonics sets as a resource category' do
      category_resource.resource_category = :phonics_sets
      expect(category_resource).not_to be_valid
    end

    it 'cannot have sight_words as a resource category' do
      category_resource.resource_category = :sight_words
      expect(category_resource).not_to be_valid
    end

    it 'cannot have slides as a resource category' do
      category_resource.resource_category = :slides
      expect(category_resource).not_to be_valid
    end
  end
end
