# frozen_string_literal: true

class AddSpecialistSubtypeFieldsToEveningClasses < ActiveRecord::Migration[7.1]
  class MigrationLesson < ActiveRecord::Base
    self.table_name = 'lessons'
    self.inheritance_column = :_type_disabled

    has_many :course_lessons,
             class_name: 'AddSpecialistSubtypeFieldsToEveningClasses::MigrationCourseLesson',
             foreign_key: :lesson_id,
             dependent: :destroy
  end

  class MigrationCourseLesson < ActiveRecord::Base
    self.table_name = 'course_lessons'
  end

  class MigrationAttachment < ActiveRecord::Base
    self.table_name = 'active_storage_attachments'
  end

  SPECIALIST_LEVELS = {
    specialist: 13,
    specialist_advanced: 14
  }.freeze
  SPECIALIST_SUBTYPES = %w[
    literacy
    discussion
    project_session_1
    project_session_2
    special_lesson
  ].freeze
  SUBTYPE_VALUE_MAP = {
    0 => 'literacy',
    1 => 'discussion',
    2 => 'project_session_1',
    3 => 'project_session_2',
    4 => 'special_lesson'
  }.freeze

  def up
    add_column :lessons, :literacy_goal, :text
    add_column :lessons, :discussion_goal, :text
    add_column :lessons, :project_session_1_goal, :text
    add_column :lessons, :project_session_2_goal, :text
    add_column :lessons, :special_lesson_goal, :text

    migrate_specialist_evening_classes
  end

  def down
    remove_column :lessons, :special_lesson_goal
    remove_column :lessons, :project_session_2_goal
    remove_column :lessons, :project_session_1_goal
    remove_column :lessons, :discussion_goal
    remove_column :lessons, :literacy_goal
  end

  private

  def migrate_specialist_evening_classes
    say_with_time 'Migrating specialist EveningClass lessons into single-lesson subtype slots' do
      specialist_lessons = MigrationLesson.where(type: 'EveningClass', level: SPECIALIST_LEVELS.values)
                                          .order(:level, :created_at, :id)

      specialist_lessons.group_by(&:level).each_value do |lessons|
        base_lesson = lessons.find { |lesson| lesson.subtype.nil? } || lessons.first

        lessons.each do |lesson|
          subtype_key = subtype_for(lesson)
          merge_goal!(base_lesson, subtype_key, lesson.goal)
          migrate_resource_attachments!(base_lesson.id, lesson.id, subtype_key)

          next if lesson.id == base_lesson.id

          reassign_course_lessons!(base_lesson.id, lesson.id)
          reassign_proposals!(base_lesson.id, lesson.id)
          lesson.destroy!
        end

        base_lesson.update_columns(subtype: nil)
      end
    end
  end

  def subtype_for(lesson)
    SUBTYPE_VALUE_MAP.fetch(lesson.subtype, 'project_session_1')
  end

  def goal_column_for(subtype_key)
    "#{subtype_key}_goal"
  end

  def attachment_name_for(subtype_key)
    "#{subtype_key}_resources"
  end

  def merge_goal!(base_lesson, subtype_key, goal)
    return if goal.blank?

    goal_column = goal_column_for(subtype_key)
    current_goal = base_lesson.public_send(goal_column)
    merged_goal = if current_goal.blank?
                    goal
                  elsif current_goal.include?(goal)
                    current_goal
                  else
                    [current_goal, goal].join("\n\n")
                  end

    base_lesson.update_columns(goal_column => merged_goal)
  end

  def migrate_resource_attachments!(base_lesson_id, source_lesson_id, subtype_key)
    source_attachments = MigrationAttachment.where(
      record_type: 'Lesson',
      record_id: source_lesson_id,
      name: 'resources'
    )

    source_attachments.find_each do |attachment|
      next if MigrationAttachment.exists?(
        record_type: 'Lesson',
        record_id: base_lesson_id,
        name: attachment_name_for(subtype_key),
        blob_id: attachment.blob_id
      )

      MigrationAttachment.create!(
        name: attachment_name_for(subtype_key),
        record_type: 'Lesson',
        record_id: base_lesson_id,
        blob_id: attachment.blob_id,
        created_at: attachment.created_at
      )
    end

    source_attachments.delete_all
  end

  def reassign_course_lessons!(base_lesson_id, source_lesson_id)
    MigrationCourseLesson.where(lesson_id: source_lesson_id).find_each do |course_lesson|
      duplicate = MigrationCourseLesson.find_by(
        lesson_id: base_lesson_id,
        course_id: course_lesson.course_id,
        week: course_lesson.week,
        day: course_lesson.day
      )

      if duplicate.present?
        course_lesson.destroy!
      else
        course_lesson.update_columns(lesson_id: base_lesson_id)
      end
    end
  end

  def reassign_proposals!(base_lesson_id, source_lesson_id)
    MigrationLesson.where(changed_lesson_id: source_lesson_id)
                   .update_all(changed_lesson_id: base_lesson_id)
  end
end
