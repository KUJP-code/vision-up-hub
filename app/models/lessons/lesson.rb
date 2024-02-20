# frozen_string_literal: true

class Lesson < ApplicationRecord
  include Approvable, Levelable, Pdfable

  TYPES = %w[DailyActivity EnglishClass Exercise PhonicsClass StandShowSpeak].freeze

  before_destroy :check_not_used

  validates :goal, :level, :title, :type, presence: true
  validates :type, inclusion: { in: TYPES }

  belongs_to :creator,
             class_name: 'User',
             optional: true
  belongs_to :assigned_editor,
             class_name: 'User',
             optional: true

  has_many :course_lessons, dependent: :destroy
  accepts_nested_attributes_for :course_lessons,
                                reject_if: :all_blank,
                                allow_destroy: true
  has_many :courses, through: :course_lessons
  has_many :proposed_changes,
           dependent: :destroy

  has_one_attached :guide do |g|
    g.variant :thumb, resize_to_limit: [300, 300], convert: :avif, preprocessed: true
  end
  has_many_attached :resources

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
    throw(:abort) if course_lessons.any?
  end
end
