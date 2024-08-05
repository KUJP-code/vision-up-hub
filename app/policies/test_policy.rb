# frozen_string_literal: true

class TestPolicy < ApplicationPolicy
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
      case user.type
      when 'Admin'
        scope.all
      when 'OrgAdmin', 'SchoolManager', 'Teacher'
        user.course_tests
      else
        scope.none
      end
    end
  end
end
