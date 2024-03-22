# frozen_string_literal: true

class Parent < User
  VISIBLE_TYPES = [].freeze

  has_many :children, class_name: 'Student',
                      dependent: :nullify
end
