# frozen_string_literal: true

class AdminPolicy < ApplicationPolicy
  SPECIAL_ADMIN_IDS = [28, 5].freeze
  def show?
    user.is?('Admin')
  end

  def new?
    user.is?('Admin') && user.ku?
  end

  def edit?
    self? || super_admin?
  end

  def create?
    user.is?('Admin') && record.ku?
  end

  def update?
    self? || super_admin?
  end

  def destroy?
    self? || super_admin?
  end

  def change_password?
    user.is?('Admin')
  end

  def new_password_change?
    user.is?('Admin')
  end

  def reassign_editor?
    user.is?('Admin')
  end

  private

  def self?
    user.is?('Admin') && user.id == record.id
  end

  def super_admin?
    admin? && SPECIAL_ADMIN_IDS.include?(user.id)
  end
end
