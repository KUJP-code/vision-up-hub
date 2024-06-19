# frozen_string_literal: true

class CategoryResourcePolicy < ApplicationPolicy
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

  def destroy?
    user.is?('Admin')
  end

  class Scope < Scope
    def resolve
      user.is?('Admin', 'Writer') ? scope.all : scope.none
      case user.type
      when 'Admin', 'Writer'
        scope.all
      when 'Teacher'
        user.category_resources
      else
        scope.none
      end
    end
  end
end
