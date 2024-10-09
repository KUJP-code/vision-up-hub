# frozen_string_literal: true

class Student < ApplicationRecord
  include Gradeable, Levelable

  CSV_HEADERS = %w[name en_name student_id level school_id parent_id
                   birthday start_date quit_date organisation_id].freeze

  after_create :generate_student_id

  has_logidze

  validates :birthday, :level, :name, presence: true
  validates :student_id, uniqueness: { allow_nil: true, scope: :organisation_id }
  encrypts :en_name, :name

  belongs_to :parent, optional: true
  belongs_to :school, counter_cache: true
  belongs_to :organisation
  delegate :organisation_id, to: :school, allow_nil: true
  has_many :teachers, through: :school

  has_many :student_classes, dependent: :destroy
  accepts_nested_attributes_for :student_classes,
                                allow_destroy: true,
                                reject_if: :all_blank
  has_many :classes, through: :student_classes,
                     source: :school_class

  has_many :test_results, dependent: :destroy
  has_many :tests, through: :test_results

  scope :current, lambda {
                    where('quit_date > ?', Time.zone.today)
                      .or(where(quit_date: nil))
                  }
  scope :former, -> { where(quit_date: ...Time.zone.today) }

  private

  def generate_student_id
    return unless student_id.nil? || student_id.blank?

    self.student_id = "#{id}-#{school_id}-#{SecureRandom.alphanumeric}"
    save
  end
end
