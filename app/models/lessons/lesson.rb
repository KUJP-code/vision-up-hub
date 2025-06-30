# frozen_string_literal: true

class Lesson < ApplicationRecord
  include Approvable, Levelable, Pdfable, Proposable, Eventable

  TYPES = %w[DailyActivity EnglishClass Exercise EveningClass KindyPhonic
             PhonicsClass SpecialLesson StandShowSpeak SeasonalActivity PartyActivity].freeze

  before_destroy :check_not_used

  acts_as_copy_target
  has_logidze

  validates :goal, :level, :title, :type, presence: true
  validates :type, inclusion: { in: TYPES }

  belongs_to :assigned_editor,
             class_name: 'User',
             optional: true
  belongs_to :creator,
             class_name: 'User',
             optional: true

  has_many :course_lessons, dependent: :destroy

  accepts_nested_attributes_for :course_lessons,
                                reject_if: :all_blank,
                                allow_destroy: true
  has_many :courses, through: :course_lessons

  has_many_attached :resources

  scope :levelled, lambda {
                     where(type: %w[EnglishClass EveningClass KindyPhonic
                                    PhonicsClass StandShowSpeak])
                   }
  scope :released, -> { where(released: true) }
  scope :unlevelled,
        -> { where(type: %w[DailyActivity Exercise SpecialLesson SeasonalActivity PartyActivity]) }

  def self.reassign_editor(old_editor_id, new_editor_id)
    Lesson.where(assigned_editor_id: old_editor_id)
          .update(assigned_editor_id: new_editor_id)
  end

  def self.policy_class
    LessonPolicy
  end

  def day(course)
    course_lessons.find_by(course_id: course.id).day.capitalize
  end

  def week(course)
    number = course_lessons.find_by(course_id: course.id).week
    "Week #{number}"
  end

  private

  def check_not_used
    return true if course_lessons.reload.empty?

    errors.add(:course_lessons,
               :invalid,
               message: 'Cannot delete lesson if it is used in a course')
    throw :abort
  end
end
