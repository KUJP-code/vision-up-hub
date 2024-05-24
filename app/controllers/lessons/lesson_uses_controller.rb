# frozen_string_literal: true

class LessonUsesController < ApplicationController
  after_action :verify_authorized, only: %i[index]

  def index
    authorize Lesson, policy_class: LessonUsesPolicy
    @lessons = policy_scope(Lesson.order(title: :asc).select(:id, :title).includes(:course_lessons))
    @courses = Course.order(title: :asc).select(:id, :title)
  end
end
