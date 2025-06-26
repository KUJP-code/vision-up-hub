# frozen_string_literal: true

class Student < ApplicationRecord
  include Gradeable, Levelable

  CSV_HEADERS = %w[name en_name student_id level school_id parent_id
                   birthday start_date quit_date sex status organisation_id].freeze
  ICON_CHOICES = %w[
    id-art id-boy id-cat id-dino id-dog id-girl id-mic id-music id-robot id-soccer id-princess id-unicorn
  ].freeze

  def self.icon_choices
    ICON_CHOICES
  end

  def self.display_levels
    [
      { name: 'land_one', order: 1 },
      { name: 'land_two', order: 2 },
      { name: 'sky_one', order: 3 },
      { name: 'sky_two', order: 4 },
      { name: 'galaxy_one', order: 5 },
      { name: 'galaxy_two', order: 6 },
      { name: 'keep_up_one', order: 7 },
      { name: 'specialist', order: 8 }
    ]
  end
  enum sex: { undefined: 0, male: 1, female: 2 }
  enum status: { active: 0, on_break: 1, inactive: 2 }
  before_validation :generate_student_id
  after_update :track_manual_level_change, if: :saved_change_to_level?

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
  has_many :level_changes, dependent: :destroy

  scope :current, -> { where(status: :active) }
  scope :former, -> { where(status: %i[on_break inactive]) }
  scope :with_recent_results, ->(cutoff) {
    joins(:test_results)
      .where('test_results.created_at >= ?', cutoff)
      .distinct
  }
  
  def mapped_level_order
    LEVEL_ORDER_MAP[level] || 1
  end

  def reached_level_change_for_order(order)
    levels_for_order = LEVEL_ORDER_MAP.select { |_, v| v == order }.keys
    level_changes.where(new_level: levels_for_order).max_by(&:date_changed)
  end

  def most_recent_valid_level_change_for(level)
    level_changes
      .where(prev_level: level)
      .select(&:leveled_up?)
      .max_by(&:date_changed)
  end

  def passed_level?(level)
    most_recent_valid_level_change_for(level).present?
  end

  def current_grade
    return 'Unknown' if birthday.nil?

    current_date = Time.zone.today
    school_year_start = Date.new(current_date.year, 4, 1)
    school_year_start -= 1.year if current_date < school_year_start
    age_at_school_year_start = school_year_start.year - birthday.year
    age_at_school_year_start -= 1 if birthday.month > 4 || (birthday.month == 4 && birthday.day > 1)
    case age_at_school_year_start
    when 6..11
      "ele#{age_at_school_year_start - 5}"
    when 12..14
      "jhs#{age_at_school_year_start - 11}"
    when 15..17
      "hs#{age_at_school_year_start - 14}"
    else
      'Kindy'
    end
  end

  private

  def track_manual_level_change(test_result = nil)
    previous_level, new_level = saved_change_to_level
    return if previous_level == new_level

    existing_level_change = LevelChange.find_by(
      student_id: id,
      new_level:,
      date_changed: Time.zone.today
    )

    return if existing_level_change

    LevelChange.create!(
      student_id: id,
      test_result_id: test_result&.id,
      new_level:,
      prev_level: previous_level,
      date_changed: Time.zone.today
    )
  end

  def generate_student_id
    return unless student_id.nil? || student_id.blank?

    self.student_id = "#{organisation_id}-#{school_id}-#{SecureRandom.alphanumeric}"
    save
  end
end
