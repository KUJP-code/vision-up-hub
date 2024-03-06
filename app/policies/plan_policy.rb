# frozen_string_literal: true

class PlanPolicy < ApplicationPolicy
  def index?
    user.is?('Admin', 'Sales')
  end

  def show?
    user.is?('Admin', 'Sales')
  end

  def new?
    user.is?('Admin', 'Sales')
  end

  def edit?
    user.is?('Admin', 'Sales')
  end

  def update?
    user.is?('Admin', 'Sales')
  end

  def create?
    user.is?('Admin', 'Sales')
  end

  def destroy?
    user.is?('Admin', 'Sales')
  end

  class Scope < Scope
    def resolve
      user.is?('Admin', 'Sales') ? scope.all : scope.none
    end
  end
end
