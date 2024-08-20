# frozen_string_literal: true

class CategoryResource < ApplicationRecord
  before_destroy :check_not_used

  enum lesson_category: {
    phonics_class: 0,
    brush_up: 1,
    snack: 2,
    get_up_and_go: 3,
    daily_gathering: 4,
    arrival: 5,
    bus_time: 6,
    evening_class: 7
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

  validates :lesson_category, :resource_category, presence: true
  validate :valid_combo

  has_many :course_resources, dependent: :destroy
  accepts_nested_attributes_for :course_resources,
                                allow_destroy: true,
                                reject_if: :all_blank
  has_many :courses, through: :course_resources

  has_one_attached :resource

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

  def arrival_resource?
    true
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
    return true if %w[worksheets slides].include?(resource_category)

    errors.add(:lesson_category, 'Get Up & Go requires a worksheet or slide resource')
    false
  end

  def daily_gathering_resource?
    return true if %w[worksheets slides].include?(resource_category)

    errors.add(:lesson_category, 'Daily Gathering requires a worksheet or slide resource')
    false
  end
end
