# frozen_string_literal: true

module LessonCreator
  extend ActiveSupport::Concern

  included do
    has_many :assigned_lessons,
             -> { where(status: :accepted) },
             class_name: 'Lesson',
             dependent: :restrict_with_error,
             foreign_key: :assigned_editor_id,
             inverse_of: :assigned_editor
    has_many :created_lessons,
             -> { where(status: :accepted) },
             class_name: 'Lesson',
             dependent: :restrict_with_error,
             foreign_key: :creator_id,
             inverse_of: :creator
    has_many :proposals,
             -> { where(status: %i[changes_needed proposed rejected]) },
             class_name: 'Lesson',
             inverse_of: :creator,
             foreign_key: :creator_id,
             dependent: :restrict_with_error
  end
end
