# frozen_string_literal: true

class LessonPolicy < ApplicationPolicy
  def index?
    authorized_ku_staff?
  end

  def show?
    authorized_ku_staff?
  end

  def new?
    authorized_ku_staff?
  end

  def edit?
    authorized_ku_staff?
  end

  def update?
    authorized_ku_staff?
  end

  def create?
    authorized_ku_staff?
  end

  def destroy?
    authorized_ku_staff?
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

    def authorized_ku_staff?
      user.is?('Admin', 'Writer')
    end
  end

  private

  def authorized_ku_staff?
    user.is?('Admin', 'Writer')
  end
end
