# frozen_string_literal: true

class TutorialCategoryPolicy < ApplicationPolicy
  def show?
    true
  end

  def new?
    user.is?('Admin', 'Sales')
  end

  def edit?
    user.is?('Admin', 'Sales')
  end

  def create?
    user.is?('Admin', 'Sales')
  end

  def update?
    user.is?('Admin', 'Sales')
  end

  def destroy?
    user.is?('Admin', 'Sales')
  end
end
