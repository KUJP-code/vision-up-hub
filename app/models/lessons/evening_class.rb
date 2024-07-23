# frozen_string_literal: true

class EveningClass < Lesson
  ATTRIBUTES = %i[].freeze
  LISTABLE_ATTRIBUTES = %i[].freeze

  enum level: {
    keep_up_one: 11,
    keep_up_two: 12,
    specialist: 13,
    specialist_advanced: 14,
    tech_up: 15
  }
end
