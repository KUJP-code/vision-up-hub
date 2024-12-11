# frozen_string_literal: true

class SeasonalActivity < Lesson
  before_validation :set_default_level
  has_one_attached :ele_english_class
  has_one_attached :kindy_english_class
  has_one_attached :scrapbook

  validates :title, :goal, presence: true
  validates :event_date, :show_from, :show_until, presence: true

  ATTRIBUTES = %i[
    title
    goal
    ele_english_class
    kindy_english_class
    resources
    scrapbook
    event_date
    show_from
    show_until
  ].freeze
  LISTABLE_ATTRIBUTES = %i[].freeze
end

private

def set_default_level
  self.level ||= :all_levels
end
