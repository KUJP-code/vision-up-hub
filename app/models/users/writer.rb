# frozen_string_literal: true

class Writer < User
  include KUStaffable, LessonCreator

  VISIBLE_TYPES = %w[Writer].freeze

  belongs_to :organisation
end
