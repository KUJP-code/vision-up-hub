# frozen_string_literal: true

class SeasonalActivity < Lesson
  has_one_attached :ele_english_class
  has_one_attached :kindy_english_class
  has_many_attached :resources
  has_one_attached :scrapbook

  validates :title, :goal, presence: true
  validates :event_date, :show_from, :show_until, presence: true

  ATTRIBUTES = %i[
    title
    goal
    ele_english_class
    kindy_english_class
    guides
    scrapbook
    event_date
    show_from
    show_until
  ].freeze
end
