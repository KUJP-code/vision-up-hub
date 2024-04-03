# frozen_string_literal: true

class Admin < User
  include KUStaffable, LessonCreator

  VISIBLE_TYPES = %w[Admin OrgAdmin Parent Sales SchoolManager Teacher Writer].freeze
end
