# frozen_string_literal: true

class PartyActivity < Lesson
  include Eventable

  before_validation :set_default_level
  has_one_attached :cover_image

  validates :title, :goal, presence: true

  ATTRIBUTES = %i[
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
