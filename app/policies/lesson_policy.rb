# frozen_string_literal: true

class LessonPolicy < ApplicationPolicy
  def index?
    view_lessons?
  end

  def show?
    view_lessons?
  end

  def new?
    manage_lessons?
  end

  def edit?
    manage_lessons?
  end

  def update?
    manage_lessons?
  end

  def create?
    manage_lessons?
  end

  def destroy?
    manage_lessons?
  end

  class Scope < Scope
    def resolve
      case user.type
      when 'Admin', 'Writer'
        scope.all
      when 'OrgAdmin', 'SchoolManager', 'Teacher'
        user.lessons
      else
        scope.none
      end
    end
  end

  private

  def manage_lessons?
    user.is?('Admin', 'Writer')
  end

  def view_lessons?
    manage_lessons? || user.is?('OrgAdmin', 'SchoolManager', 'Teacher')
  end
end
