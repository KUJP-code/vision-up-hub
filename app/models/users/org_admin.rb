# frozen_string_literal: true

class OrgAdmin < User
  VISIBLE_TYPES = %w[OrgAdmin SchoolManager Teacher].freeze

  belongs_to :organisation
  delegate :schools, to: :organisation
end
