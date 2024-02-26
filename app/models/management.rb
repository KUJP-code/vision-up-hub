# frozen_string_literal: true

class Management < ApplicationRecord
  validate :sm_is_sm

  belongs_to :school
  belongs_to :school_manager

  private

  def sm_is_sm
    errors.add(:user, 'is not a school manager') unless school_manager.is?('SchoolManager')
  end
end
