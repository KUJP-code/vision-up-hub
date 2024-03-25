# frozen_string_literal: true

class Parent < User
  VISIBLE_TYPES = [].freeze

  has_many :children, class_name: 'Student',
                      inverse_of: :parent,
                      dependent: :nullify
end
