# frozen_string_literal: true

class Writer < User
  include KUStaffable, LessonCreatable

  VISIBLE_TYPES = %w[Writer].freeze
end
