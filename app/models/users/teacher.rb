# frozen_string_literal: true

class Teacher < User
  VISIBLE_TYPES = %w[].freeze

  belongs_to :organisation
  belongs_to :school
end
