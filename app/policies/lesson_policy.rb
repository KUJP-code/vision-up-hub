# frozen_string_literal: true

class LessonPolicy < ApplicationPolicy
  def index?
    user.is?('Admin', 'Writer')
  end

  def show?
    user.is?('Admin', 'Writer')
  end

  def new?
    user.is?('Admin', 'Writer')
  end

  def edit?
    user.is?('Admin', 'Writer')
  end

  def update?
    user.is?('Admin', 'Writer')
  end

  def create?
    user.is?('Admin', 'Writer')
  end

  class Scope
    def resolve
      scope
    end
  end
end
