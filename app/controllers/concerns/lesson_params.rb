# frozen_string_literal: true

module LessonParams
  extend ActiveSupport::Concern

  included do
    private

    def lesson_params(type)
      params.require(type).permit(:course_id, :day, :summary, :title, :type, :week)
    end
  end
end
