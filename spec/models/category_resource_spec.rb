# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CategoryResource do
  let(:category_resource) { build(:category_resource) }

  it 'has a valid factory' do
    expect(category_resource).to be_valid
  end

  context 'when resource for phonics class' do
    before do
      category_resource.lesson_category = :phonics_class
    end

    it 'can have phonics set as a resource category' do
      category_resource.resource_category = :phonics_set
      expect(category_resource).to be_valid
    end

    it 'can have word family as a resource category' do
      category_resource.resource_category = :word_family
      expect(category_resource).to be_valid
    end

    it 'can have sight words as a resource category' do
      category_resource.resource_category = :sight_words
      expect(category_resource).to be_valid
    end

    it 'cannot have worksheet as a resource category' do
      category_resource.resource_category = :worksheet
      expect(category_resource).not_to be_valid
    end

    it 'cannot have slides as a resource category' do
      category_resource.resource_category = :slides
      expect(category_resource).not_to be_valid
    end
  end

  context 'when resource for brush up' do
    before do
      category_resource.lesson_category = :brush_up
    end

    it 'cannnot have phonics set as a resource category' do
      category_resource.resource_category = :phonics_set
      expect(category_resource).not_to be_valid
    end

    it 'cannot have word family as a resource category' do
      category_resource.resource_category = :word_family
      expect(category_resource).not_to be_valid
    end

    it 'cannot have sight words as a resource category' do
      category_resource.resource_category = :sight_words
      expect(category_resource).not_to be_valid
    end

    it 'can have worksheet as a resource category' do
      category_resource.resource_category = :worksheet
      expect(category_resource).to be_valid
    end

    it 'cannot have slides as a resource category' do
      category_resource.resource_category = :slides
      expect(category_resource).not_to be_valid
    end
  end

  context 'when resource for snack' do
    before do
      category_resource.lesson_category = :snack
    end

    it 'cannot have phonics set as a resource category' do
      category_resource.resource_category = :phonics_set
      expect(category_resource).not_to be_valid
    end

    it 'cannot have word family as a resource category' do
      category_resource.resource_category = :word_family
      expect(category_resource).not_to be_valid
    end

    it 'cannot have sight words as a resource category' do
      category_resource.resource_category = :sight_words
      expect(category_resource).not_to be_valid
    end

    it 'can have worksheet as a resource category' do
      category_resource.resource_category = :worksheet
      expect(category_resource).to be_valid
    end

    it 'can have slides as a resource category' do
      category_resource.resource_category = :slides
      expect(category_resource).to be_valid
    end
  end

  context 'when resource for get up & go' do
    before do
      category_resource.lesson_category = :up_and_go
    end

    it 'cannot have phonics set as a resource category' do
      category_resource.resource_category = :phonics_set
      expect(category_resource).not_to be_valid
    end

    it 'cannot have word family as a resource category' do
      category_resource.resource_category = :word_family
      expect(category_resource).not_to be_valid
    end

    it 'cannot have sight words as a resource category' do
      category_resource.resource_category = :sight_words
      expect(category_resource).not_to be_valid
    end

    it 'can have worksheet as a resource category' do
      category_resource.resource_category = :worksheet
      expect(category_resource).to be_valid
    end

    it 'can have slides as a resource category' do
      category_resource.resource_category = :slides
      expect(category_resource).to be_valid
    end
  end

  context 'when resource for daily gathering' do
    before do
      category_resource.lesson_category = :daily_gathering
    end

    it 'cannot have phonics set as a resource category' do
      category_resource.resource_category = :phonics_set
      expect(category_resource).not_to be_valid
    end

    it 'cannot have word family as a resource category' do
      category_resource.resource_category = :word_family
      expect(category_resource).not_to be_valid
    end

    it 'cannot have sight words as a resource category' do
      category_resource.resource_category = :sight_words
      expect(category_resource).not_to be_valid
    end

    it 'can have worksheet as a resource category' do
      category_resource.resource_category = :worksheet
      expect(category_resource).to be_valid
    end

    it 'can have slides as a resource category' do
      category_resource.resource_category = :slides
      expect(category_resource).to be_valid
    end
  end
end
