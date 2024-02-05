# frozen_string_literal: true

class Lesson < ApplicationRecord
  require 'prawn'

  TYPES = %w[DailyActivity EnglishClass Exercise PhonicsClass].freeze

  before_validation :set_icon_path
  before_save :attach_guide
  before_destroy :check_not_used

  validates :goal, :icon, :level, :title, :type, presence: true
  validates :type, inclusion: { in: TYPES }

  enum level: {
    all_levels: 0,
    kindy: 1,
    land_one: 2,
    land_two: 3,
    sky_one: 4,
    sky_two: 5,
    galaxy_one: 6,
    galaxy_two: 7,
    keep_up: 8,
    specialist: 9
  }

  has_one_attached :guide do |g|
    g.variant :thumb, resize_to_limit: [400, 400], convert: :avif, preprocessed: true
  end

  has_many :course_lessons, dependent: :destroy
  accepts_nested_attributes_for :course_lessons,
                                reject_if: :all_blank,
                                allow_destroy: true
  has_many :courses, through: :course_lessons

  def attach_guide
    filename = "#{Time.zone.now}_#{title.parameterize(separator: '_')}_guide.pdf"
    pdf_io = guide_tempfile
    pdf_blob = ActiveStorage::Blob.create_and_upload!(
      io: pdf_io, filename:, content_type: 'application/pdf'
    )
    self.guide = pdf_blob
    pdf_io
  end

  def day(course)
    course_lessons.find_by(course_id: course.id).day.capitalize
  end

  def week(course)
    number = course_lessons.find_by(course_id: course.id).week
    "Week #{number}"
  end

  def self.policy_class
    LessonPolicy
  end

  private

  def check_not_used
    throw(:abort) if course_lessons.any?
  end

  def guide_tempfile
    Tempfile.create do |f|
      generate_guide.render_file(f)
      File.open(f)
    end
  end

  # TODO: actually create this
  def set_icon_path
    self.icon = 'dummy path, implement later'
  end
end
