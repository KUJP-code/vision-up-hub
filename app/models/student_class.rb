# frozen_string_literal: true

class StudentClass < ApplicationRecord
  belongs_to :school_class,
             foreign_key: :class_id,
             inverse_of: :student_classes
  belongs_to :student, inverse_of: :student_classes
end
