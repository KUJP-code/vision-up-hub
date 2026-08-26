# frozen_string_literal: true

class TutorialSectionPolicy < ApplicationPolicy
  def show?
    true
  end

  def new?
    manage?
  end

  def create?
    manage?
  end

  def edit?
    manage?
  end

  def update?
    manage?
  end

  def destroy?
    manage?
  end

  private

  def manage?
    user.is?('Admin', 'Sales')
  end
end
