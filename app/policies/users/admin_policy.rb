# frozen_string_literal: true

class AdminPolicy < ApplicationPolicy
  def show?
    user.is?('Admin')
  end

  def new?
    user.is?('Admin') && user.ku?
  end

  def edit?
    self?
  end

  def create?
    user.is?('Admin') && record.ku?
  end

  def update?
    self?
  end

  def destroy?
    self?
  end

  def reassign_editor?
    user.is?('Admin')
  end

  private

  def self?
    user.is?('Admin') && user.id == record.id
  end
end
