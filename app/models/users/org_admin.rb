# frozen_string_literal: true

class OrgAdmin < User
  include Supportable

  VISIBLE_TYPES = %w[OrgAdmin SchoolManager Teacher].freeze

  belongs_to :organisation
  delegate :schools, to: :organisation
end
