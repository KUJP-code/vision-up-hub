# frozen_string_literal: true

class CategoryResource < ApplicationRecord
  enum lesson_category: {
    phonics_class: 0,
    brush_up: 1,
    snack: 2,
    up_and_go: 3,
    daily_gathering: 4
  }

  enum resource_category: {
    phonics_set: 0,
    word_family: 1,
    sight_words: 2,
    worksheet: 3,
    slides: 4
  }

  validates :lesson_category, :resource_category, presence: true
  validate :valid_combo

  has_many :course_resources, dependent: :destroy
  accepts_nested_attributes_for :course_resources,
                                allow_destroy: true,
                                reject_if: :all_blank
  has_many :courses, through: :course_resources

  has_one_attached :resource

  private

  def valid_combo
    send(:"#{lesson_category}_resource?")
  end

  def phonics_class_resource?
    return true if %w[phonics_set word_family sight_words].include?(resource_category)

    errors.add(:resource_category,
               'Phonics Class requires a phonics set, word family, or sight words resource')
    false
  end

  def brush_up_resource?
    return true if resource_category == 'worksheet'

    errors.add(:resource_category, 'Brush Up requires a worksheet resource')
    false
  end

  def snack_resource?
    return true if %w[worksheet slides].include?(resource_category)

    errors.add(:resource_category, 'Snack requires a worksheet or slides resource')
    false
  end

  def up_and_go_resource?
    return true if %w[worksheet slides].include?(resource_category)

    errors.add(:resource_category, 'Get Up & Go requires a worksheet or slides resource')
    false
  end

  def daily_gathering_resource?
    return true if %w[worksheet slides].include?(resource_category)

    errors.add(:resource_category, 'Daily Gathering requires a worksheet or slides resource')
    false
  end
end
