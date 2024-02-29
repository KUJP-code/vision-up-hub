# frozen_string_literal: true

class CoursePolicy < ApplicationPolicy
  def index?
    user.is?('Admin')
  end

  def show?
    user.is?('Admin')
  end

  def new?
    user.is?('Admin')
  end

  def edit?
    user.is?('Admin')
  end

  def update?
    user.is?('Admin')
  end

  def create?
    user.is?('Admin')
  end

  def destroy?
    user.is?('Admin')
  end

  class Scope < Scope
    def resolve
      user.is?('Admin') ? scope.all : scope.none
    end
  end
end
