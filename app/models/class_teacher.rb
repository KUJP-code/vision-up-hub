# frozen_string_literal: true

class ClassTeacher < ApplicationRecord
  belongs_to :school_class,
             foreign_key: :class_id,
             inverse_of: :class_teachers
  belongs_to :teacher, inverse_of: :class_teachers
end
