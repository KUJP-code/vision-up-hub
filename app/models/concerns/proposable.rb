# frozen_string_literal: true

module Proposable
  extend ActiveSupport::Concern

  included do
    belongs_to :changed_lesson,
               class_name: 'Lesson',
               optional: true

    has_many :proposals, class_name: 'Lesson',
                         foreign_key: :changed_lesson_id,
                         inverse_of: :changed_lesson,
                         dependent: :nullify
    enum status: {
      proposed: 0,
      changes_needed: 1,
      rejected: 2,
      accepted: 3
    }
  end
end
