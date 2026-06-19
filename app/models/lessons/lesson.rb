# frozen_string_literal: true

class Lesson < ApplicationRecord
  include Approvable, Levelable, Pdfable, Proposable, Eventable

  TYPES = %w[DailyActivity EnglishClass Exercise EveningClass KindyPhonic
             PhonicsClass SpecialLesson StandShowSpeak SeasonalActivity EventActivity PartyActivity
             ParentsReport].freeze

  before_destroy :check_not_used

  acts_as_copy_target
  has_logidze

  validates :level, :title, :type, presence: true
  validates :type, inclusion: { in: TYPES }

  belongs_to :assigned_editor,
             class_name: 'User',
             optional: true
  belongs_to :creator,
             class_name: 'User',
             optional: true

  has_many :course_lessons, dependent: :destroy
  has_many :lesson_links, dependent: :destroy
  accepts_nested_attributes_for :lesson_links, allow_destroy: true
  accepts_nested_attributes_for :course_lessons,
                                reject_if: :all_blank,
                                allow_destroy: true
  has_many :courses, through: :course_lessons

  has_many_attached :resources

  def resource_deletion_blob_ids(attachment_name)
    Array(resource_deletions.to_h[attachment_name.to_s]).filter_map(&:presence).map(&:to_i)
  end

  def resource_deleted?(attachment_name, blob_or_id)
    blob_id = blob_or_id.respond_to?(:id) ? blob_or_id.id : blob_or_id

    resource_deletion_blob_ids(attachment_name).include?(blob_id.to_i)
  end

  def apply_resource_deletions!
    resource_deletions.to_h.each do |attachment_name, blob_ids|
      next unless attachment_reflections.key?(attachment_name)

      ids = Array(blob_ids).filter_map(&:presence).map(&:to_i)
      public_send(:"#{attachment_name}_attachments").where(blob_id: ids).find_each(&:purge)
    end

    update!(resource_deletions: {}) if persisted? && resource_deletions.present?
  end

  scope :levelled, lambda {
                     where(type: %w[EnglishClass EveningClass KindyPhonic
                                    PhonicsClass StandShowSpeak])
                   }
  scope :canonical, -> { where(changed_lesson_id: nil) }
  scope :released, -> { where(released: true) }
  scope :unlevelled,
        lambda {
          where(type: %w[DailyActivity Exercise SpecialLesson SeasonalActivity EventActivity PartyActivity
                         ParentsReport])
        }

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
