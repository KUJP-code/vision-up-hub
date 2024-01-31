# frozen_string_literal: true

class OrgAdmin < User
  VISIBLE_TYPES = %w[OrgAdmin SchoolManager Teacher].freeze
end
