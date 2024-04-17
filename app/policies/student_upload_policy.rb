# frozen_string_literal: true

class StudentUploadPolicy < ApplicationPolicy
  def index?
    false
  end

  def show?
    false
  end

  def new?
    user.is?('Admin', 'OrgAdmin')
  end

  def edit?
    false
  end

  def update?
    user.is?('Admin', 'OrgAdmin')
  end

  def create?
    user.is?('Admin', 'OrgAdmin')
  end

  def destroy?
    false
  end
end
