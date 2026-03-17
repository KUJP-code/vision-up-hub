# frozen_string_literal: true

class SchoolTeacher < ApplicationRecord
  belongs_to :school
  belongs_to :teacher

  validate :teacher_school_organisation_matches

  private

  def teacher_school_organisation_matches
    return if school.blank? || teacher.blank?
    return if school.organisation_id == teacher.organisation_id

    errors.add(:school, 'must belong to the same organisation as the teacher')
  end
end
