# frozen_string_literal: true

class NotificationPolicy < ApplicationPolicy
  def show?
    true
  end

  def new?
    user.is?('Admin')
  end

  def create?
    user.is?('Admin')
  end

  def update?
    true
  end

  def destroy?
    true
  end
end
