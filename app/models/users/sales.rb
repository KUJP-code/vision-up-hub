# frozen_string_literal: true

class Sales < User
  include KUStaffable

  VISIBLE_TYPES = %w[OrgAdmin SchoolManager Sales Teacher].freeze

  belongs_to :organisation
end
