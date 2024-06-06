# frozen_string_literal: true

class FilePolicy < ApplicationPolicy
  def show?
    user.is?('Admin', 'OrgAdmin', 'SchoolManager', 'Teacher', 'Writer')
  end

  def destroy?
    user.is?('Admin')
  end
end
