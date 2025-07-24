# frozen_string_literal: true

class EventActivity < Lesson
  include Eventable

  before_validation :set_default_level
  has_one_attached :cover_image
  has_one_attached :activity_guide

  validates :title, :goal, presence: true

  ATTRIBUTES = %i[
    activity_guide
    title
    goal
    resources
    cover_image
  ].freeze
  LISTABLE_ATTRIBUTES = %i[].freeze
end

private

def set_default_level
  self.level ||= :all_levels
end