# frozen_string_literal: true

class Student < ApplicationRecord
  include Gradeable, Levelable
  SS_CSV_HEADERS = %w[school_id name en_name student_id level quit_date birthday
                      status land_1_date land_2_date sky_1_date sky_2_date galaxy_1_date galaxy_2_date].freeze
  CSV_HEADERS = %w[name en_name student_id level school_id parent_id
                   birthday start_date quit_date organisation_id].freeze
  ICON_CHOICES = %w[
    id-art id-boy id-cat id-dino id-dog id-girl id-mic id-music id-robot id-soccer
  ].freeze

  def self.icon_choices
    ICON_CHOICES
  end
  enum sex: { undefined: 0, male: 1, female: 2 }
  enum status: { active: 0, on_break: 1, inactive: 2 }
  before_validation :generate_student_id

  has_logidze
  validates :birthday, :status, :level, :name, :sex, presence: true
  validates :student_id, presence: true, uniqueness: { scope: :organisation_id }
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

    self.student_id = "#{organisation_id}-#{school_id}-#{SecureRandom.alphanumeric}"
    save
  end
end
