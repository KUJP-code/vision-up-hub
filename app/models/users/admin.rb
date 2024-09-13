# frozen_string_literal: true

class Admin < User
  include KUStaffable, LessonConsumable, LessonCreatable

  VISIBLE_TYPES = %w[Admin OrgAdmin Parent Sales SchoolManager Teacher Writer].freeze
end
