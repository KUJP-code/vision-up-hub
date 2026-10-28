# frozen_string_literal: true

class AiSenseiPolicy < ApplicationPolicy
  def new?
    user.is?('Admin')
  end

  def create?
    user.is?('Admin')
  end

  def edit?
    user.is?('Admin')
  end

  def update?
    user.is?('Admin')
  end

  def destroy?
    user.is?('Admin')
  end
end
