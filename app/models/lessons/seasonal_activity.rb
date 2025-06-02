# frozen_string_literal: true

class SeasonalActivity < Lesson
  include Eventable

  before_validation :set_default_level
  has_one_attached :ele_english_class
  has_one_attached :kindy_english_class
  has_one_attached :scrapbook
  has_one_attached :activity_guide
  has_one_attached :cover_image

  validates :title, :goal, presence: true

  ATTRIBUTES = %i[
    title
    goal
    ele_english_class
    kindy_english_class
    resources
    scrapbook
    activity_guide
    cover_image
  ].freeze
  LISTABLE_ATTRIBUTES = %i[].freeze
end

private

def set_default_level
  self.level ||= :all_levels
end
