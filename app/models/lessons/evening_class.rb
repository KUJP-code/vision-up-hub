# frozen_string_literal: true

class EveningClass < Lesson
  KEEP_UP_SUBTYPES = %w[conversation_time topic_study special_lesson].freeze
  SPECIALIST_SUBTYPES = %w[
    literacy discussion project_session_1 project_session_2 special_lesson
  ].freeze
  SPECIALIST_GOAL_ATTRIBUTES = %i[
    literacy_goal
    discussion_goal
    project_session_1_goal
    project_session_2_goal
    special_lesson_goal
  ].freeze
  LEVEL_SUBTYPE_MAP = {
    'keep_up' => KEEP_UP_SUBTYPES,
    'keep_up_one' => KEEP_UP_SUBTYPES,
    'keep_up_two' => KEEP_UP_SUBTYPES,
    'specialist' => SPECIALIST_SUBTYPES,
    'specialist_advanced' => SPECIALIST_SUBTYPES
  }.freeze

  ATTRIBUTES = %i[
    subtype
    literacy_goal
    discussion_goal
    project_session_1_goal
    project_session_2_goal
    special_lesson_goal
  ].freeze
  LISTABLE_ATTRIBUTES = %i[].freeze

  validates :subtype, presence: true, unless: :specialist?
  validate :subtype_matches_level

  enum level: {
    keep_up_one: 11,
    keep_up_two: 12,
    specialist: 13,
    specialist_advanced: 14,
    tech_up: 15
  }

  enum subtype: {
    literacy: 0,
    discussion: 1,
    project_session_1: 2,
    project_session_2: 3,
    special_lesson: 4,
    conversation_time: 5,
    topic_study: 6
  }

  has_many_attached :literacy_resources
  has_many_attached :discussion_resources
  has_many_attached :project_session_1_resources
  has_many_attached :project_session_2_resources
  has_many_attached :special_lesson_resources

  def self.subtypes_for(level)
    LEVEL_SUBTYPE_MAP.fetch(level.to_s, [])
  end

  def self.levels_for_subtype(subtype)
    LEVEL_SUBTYPE_MAP.select { |_level, subtypes| subtypes.include?(subtype.to_s) }.keys
  end

  def specialist_structured?
    specialist? && subtype.blank?
  end

  def specialist_goal_for(subtype_key)
    public_send("#{subtype_key}_goal")
  end

  def specialist_resources_for(subtype_key)
    public_send("#{subtype_key}_resources_attachments")
  end

  def specialist_subtype_present?(subtype_key)
    specialist_goal_for(subtype_key).present? || specialist_resources_for(subtype_key).any?
  end

  def specialist_subtypes_with_content
    SPECIALIST_SUBTYPES.select { |subtype_key| specialist_subtype_present?(subtype_key) }
  end

  def self.specialist_resource_attachment_names
    SPECIALIST_SUBTYPES.map { |subtype_key| "#{subtype_key}_resources" }
  end

  private

  def subtype_matches_level
    return if subtype.blank?
    return if self.class.subtypes_for(level).include?(subtype)

    errors.add(:subtype, 'is not valid for this level')
  end
end
