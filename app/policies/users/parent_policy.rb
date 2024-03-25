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
    user.is?('Admin') || authorized_org_user?
  end

  def destroy?
    user.is?('Admin') || authorized_org_user?
  end

  private

  def authorized_org_user?
    (user.is?('OrgAdmin') && record.organisation_id == user.organisation_id) ||
      (user.is?('SchoolManager') && user.parents.ids.include?(record.id))
  end

  def viewing_self?
    user.is?('Parent') && record.id == user.id
  end
end
