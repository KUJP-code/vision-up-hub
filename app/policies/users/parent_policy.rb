# frozen_string_literal: true

class ParentPolicy < ApplicationPolicy
  def show?
    user.is?('Admin') || viewing_self? || authorized_org_user?
  end

  def new?
    user.is?('Admin', 'OrgAdmin', 'SchoolManager')
  end

  def edit?
    user.is?('Admin') || viewing_self? || authorized_org_user?
  end

  def update?
    user.is?('Admin') || viewing_self? || authorized_org_user?
  end

  def create?
    user.is?('Admin') ||
      (user.is?('OrgAdmin', 'SchoolManager') && user.organisation_id == record.organisation_id)
  end

  def destroy?
    user.is?('Admin') || authorized_org_user?
  end

  private

  def authorized_org_user?
    valid_org_admin? || valid_school_manager?
  end

  def valid_org_admin?
    user.is?('OrgAdmin') && user.organisation_id == record.organisation_id
  end

  def valid_school_manager?
    user.is?('SchoolManager') && UserPolicy::Scope.new(user, User).resolve.ids.include?(record.id)
  end

  def viewing_self?
    user.is?('Parent') && record.id == user.id
  end
end
