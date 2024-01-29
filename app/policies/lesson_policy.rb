# frozen_string_literal: true

class LessonPolicy < ApplicationPolicy
  def index?
    user.is?('Admin', 'Writer') && user.organisation.name == 'KidsUP'
  end

  def show?
    user.is?('Admin', 'Writer') && user.organisation.name == 'KidsUP'
  end

  def new?
    user.is?('Admin', 'Writer') && user.organisation.name == 'KidsUP'
  end

  def edit?
    user.is?('Admin', 'Writer') && user.organisation.name == 'KidsUP'
  end

  def update?
    user.is?('Admin', 'Writer') && user.organisation.name == 'KidsUP'
  end

  def create?
    user.is?('Admin', 'Writer') && user.organisation.name == 'KidsUP'
  end

  class Scope
    def resolve
      scope
    end
  end
end
