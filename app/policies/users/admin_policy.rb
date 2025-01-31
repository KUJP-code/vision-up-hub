# frozen_string_literal: true

class AdminPolicy < ApplicationPolicy
  SPECIAL_ADMIN_ID = 28
  def show?
    user.is?('Admin')
  end

  def new?
    user.is?('Admin') && user.ku?
  end

  def edit?
    self? || user.id == SPECIAL_ADMIN_ID
  end

  def create?
    user.is?('Admin') && record.ku?
  end

  def update?
    self?
  end

  def destroy?
    self? || user.id == SPECIAL_ADMIN_ID
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
end
