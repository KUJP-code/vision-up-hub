# frozen_string_literal: true

class Management < ApplicationRecord
  validate :sm_is_sm
  validate :school_manager_school_organisation_matches

  belongs_to :school
  belongs_to :school_manager

  private

  def sm_is_sm
    errors.add(:user, 'is not a school manager') unless school_manager.is?('SchoolManager')
  end

  def school_manager_school_organisation_matches
    return if school.blank? || school_manager.blank?
    return if school.organisation_id == school_manager.organisation_id

    errors.add(:school, 'must belong to the same organisation as the school manager')
  end
end
