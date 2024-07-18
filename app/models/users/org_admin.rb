# frozen_string_literal: true

class OrgAdmin < User
  include Courseable

  VISIBLE_TYPES = %w[OrgAdmin Parent SchoolManager Teacher].freeze

  has_many :schools, through: :organisation
  has_many :test_results, through: :schools
end
