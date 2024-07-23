# frozen_string_literal: true

class FilePolicy < ApplicationPolicy
  def show?
    user.is?('Admin', 'OrgAdmin', 'SchoolManager', 'Teacher', 'Writer')
  end

  def destroy?
    user.is?('Admin')
  end

  class Scope < Scope
    def resolve
      user.is?('Admin', 'Writer') ? scope.all : scope.none
    end
  end
end
