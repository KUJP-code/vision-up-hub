# frozen_string_literal: true

class OrgAdmin < User
  VISIBLE_TYPES = %w[OrgAdmin Parent SchoolManager Teacher].freeze

  belongs_to :organisation
  has_many :schools, through: :organisation
  has_many :test_results, through: :schools
end
