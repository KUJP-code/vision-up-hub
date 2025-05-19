# frozen_string_literal: true

class PartyActivity < Lesson
  before_validation :set_default_level
  has_one_attached :cover_image

  validates :title, :goal, presence: true
  validates :event_date, :show_from, :show_until, presence: true

  ATTRIBUTES = %i[
    title
    goal
    resources
    event_date
    show_from
    show_until
    cover_image
  ].freeze
  LISTABLE_ATTRIBUTES = %i[].freeze
end

private

def set_default_level
  self.level ||= :all_levels
end
