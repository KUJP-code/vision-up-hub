# frozen_string_literal: true

class TeacherToolPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      return scope.all if user.is?('Admin')

      scope.none
    end
  end

  def index?
    user.is?('Admin')
  end

  def new?
    user.is?('Admin')
  end

  def create?
    user.is?('Admin')
  end

  def edit?
    user.is?('Admin')
  end

  def update?
    user.is?('Admin')
  end

  def destroy?
    user.is?('Admin')
  end

  def reorder?
    user.is?('Admin')
  end

  def batch_copy?
    user.is?('Admin')
  end

  def batch_copy_preview?
    user.is?('Admin')
  end

  def batch_copy_create?
    user.is?('Admin')
  end
end
