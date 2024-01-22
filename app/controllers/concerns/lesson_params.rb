# frozen_string_literal: true

module LessonParams
  extend ActiveSupport::Concern

  included do
    def lesson_params
      %i[course_id day level summary title type week]
    end
  end
end
