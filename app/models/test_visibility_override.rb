# frozen_string_literal: true

class TestVisibilityOverride < ApplicationRecord
  belongs_to :user
  belongs_to :test

  validates :test_id, uniqueness: { scope: :user_id }
  validate :user_is_school_manager

  private

  def user_is_school_manager
    return if user&.is?('SchoolManager')

    errors.add(:user, 'must be a school manager')
  end
end
