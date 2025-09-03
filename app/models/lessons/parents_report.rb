# frozen_string_literal: true

class ParentsReport < Lesson

  before_validation :set_default_level

  validates :title, presence: true

  ATTRIBUTES = %i[
    title
    goal
    resources
  ].freeze
  LISTABLE_ATTRIBUTES = %i[].freeze
end

private

def set_default_level
  self.level ||= :all_levels
end
