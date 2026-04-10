# frozen_string_literal: true

class CategoryResource < ApplicationRecord
  AFTERSCHOOL_EXTRAS = %w[arrival brush_up bus_time daily_gathering friendship_time
                          get_up_and_go sensory_play snack story_and_reading].freeze

  before_destroy :check_not_used

  enum lesson_category: {
    phonics_class: 0,
    brush_up: 1,
    snack: 2,
    get_up_and_go: 3,
    daily_gathering: 4,
    arrival: 5,
    bus_time: 6,
    evening_class: 7,
    english_class: 8,
    story_and_reading: 9,
    friendship_time: 10,
    sensory_play: 11,
    ku_book_activity: 12,
    ku_lesson_review: 13
  }

  enum level: {
    all_levels: 0,
    kindy: 1,
    land: 2,
    sky: 5,
    galaxy: 8,
    keep_up: 11,
    specialist: 13
  }

  enum resource_category: {
    phonics_sets: 0,
    word_families: 1,
    sight_words: 2,
    worksheets: 3,
    slides: 4,
    activities: 5
  }

  VALID_RESOURCE_CATEGORIES = {
    'phonics_class' => %w[phonics_sets word_families sight_words],
    'brush_up' => %w[worksheets],
    'snack' => %w[worksheets slides],
    'get_up_and_go' => %w[worksheets slides activities],
    'daily_gathering' => %w[worksheets slides],
    'arrival' => resource_categories.keys,
    'bus_time' => resource_categories.keys,
    'evening_class' => %w[worksheets activities],
    'story_and_reading' => %w[worksheets slides],
    'friendship_time' => %w[worksheets slides],
    'sensory_play' => %w[worksheets slides],
    'ku_book_activity' => %w[worksheets slides],
    'ku_lesson_review' => %w[worksheets slides]
  }.freeze

  validates :lesson_category, :resource_category, presence: true
  validate :valid_combo
  validate :brush_up_level

  has_many :course_resources, dependent: :destroy
  accepts_nested_attributes_for :course_resources,
                                allow_destroy: true,
                                reject_if: :all_blank
  has_many :courses, through: :course_resources

  has_one_attached :resource

  def self.valid_resource_categories_for(lesson_category)
    VALID_RESOURCE_CATEGORIES.fetch(lesson_category.to_s, [])
  end

  def self.valid_lesson_categories_for(resource_category)
    VALID_RESOURCE_CATEGORIES.filter_map do |lesson_category, resource_categories|
      lesson_category if resource_categories.include?(resource_category.to_s)
    end
  end

  def phonics_resources
    return PhonicsResource.none unless lesson_category == 'phonics_class'

    PhonicsResource.where(blob_id: resource.blob_id)
  end

  private

  def check_not_used
    return true if course_resources.reload.empty?

    errors.add(:course_resources, :invalid,
               message: 'Cannot delete category resource if it is used in a course')
    throw :abort
  end

  def valid_combo
    send(:"#{lesson_category}_resource?")
  end

  def phonics_class_resource?
    return true if %w[phonics_sets word_families sight_words].include?(resource_category)

    errors.add(:lesson_category,
               'Phonics Class requires a phonics set, word family, or sight words resource')
    false
  end

  def evening_class_resource?
    return true if %w[activities worksheets].include?(resource_category)

    errors.add(:lesson_category,
               'Evening class requires a activity or worksheet resource')
    false
  end

  def ku_book_activity_resource?
    return true if %w[worksheets slides].include?(resource_category)

    errors.add(:lesson_category,
               'KU Book Activity requires a worksheet or slide resource')
    false
  end

  def ku_lesson_review_resource?
    return true if %w[worksheets slides].include?(resource_category)

    errors.add(:lesson_category,
               'KU Lesson Review requires a worksheet or slide resource')
    false
  end

  def arrival_resource?
    true
  end
  # TODO: remove later once homework resource migration has been run to remove it
  def english_class_resource?
  return true if resource_category == 'homework_sheet'

  errors.add(:lesson_category, 'Requires a homework resource')
  false
  end

  def brush_up_resource?
    return true if resource_category == 'worksheets'

    errors.add(:lesson_category, 'Brush Up requires a worksheet resource')
    false
  end

  def bus_time_resource?
    true
  end

  def snack_resource?
    return true if %w[worksheets slides].include?(resource_category)

    errors.add(:lesson_category, 'Snack requires a worksheet or slide resource')
    false
  end

  def get_up_and_go_resource? # rubocop:disable Naming/AccessorMethodName
    return true if %w[worksheets slides activities].include?(resource_category)

    errors.add(:lesson_category, 'Get Up & Go requires a worksheet, activity or slide resource')
    false
  end

  def daily_gathering_resource?
    return true if %w[worksheets slides].include?(resource_category)

    errors.add(:lesson_category, 'Daily Gathering requires a worksheet or slide resource')
    false
  end

  def story_and_reading_resource?
    return true if %w[worksheets slides].include?(resource_category)

    errors.add(:lesson_category, 'Story & Reading requires a worksheet or slide resource')
    false
  end

  def sensory_play_resource?
    return true if %w[worksheets slides].include?(resource_category)

    errors.add(:lesson_category, 'Sensory Play requires a worksheet or slide resource')
    false
  end

  def friendship_time_resource?
    return true if %w[worksheets slides].include?(resource_category)

    errors.add(:lesson_category, 'Friendship Time requires a worksheet or slide resource')
    false
  end

  def brush_up_level
    return unless brush_up? && all_levels?

    errors.add(:level, 'Brush Up cannot be all levels')
  end
end
