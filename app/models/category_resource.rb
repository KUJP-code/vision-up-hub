# frozen_string_literal: true

class CategoryResource < ApplicationRecord
  has_one_attached :resource

  enum lesson_category: {
    phonics_class: 0,
    brush_up: 1,
    snack: 2,
    get_up_and_go: 3,
    daily_gathering: 4
  }

  enum resource_category: {
    phonics_set: 0,
    word_family: 1,
    sight_words: 2,
    worksheet: 3,
    slides: 4
  }
end
