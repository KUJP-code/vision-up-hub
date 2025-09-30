# frozen_string_literal: true

class TutorialCategoryPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      user.is?('Admin', 'Sales')

      return scope.none if user.organisation_id.blank?

      scope
        .joins(:organisation_tutorial_categories)
        .where(organisation_tutorial_categories: { organisation_id: user.organisation_id })
        .distinct
    end
  end

  def show?
    return true if user.is?('Admin', 'Sales')
    return false if user.organisation_id.blank?

    record.organisations.exists?(id: user.organisation_id)
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
