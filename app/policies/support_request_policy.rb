# frozen_string_literal: true

class SupportRequestPolicy < ApplicationPolicy
  def show?
    authorized_ku_staff? || requester? || requester_manager?
  end

  def new?
    true
  end

  def edit?
    authorized_ku_staff? || requester? || requester_manager?
  end

  def update?
    authorized_ku_staff? || requester? || requester_manager?
  end

  def create?
    authorized_ku_staff? || requester? || requester_manager?
  end

  def destroy?
    authorized_ku_staff? || requester? || requester_manager?
  end

  class Scope < Scope
    def resolve
    end
  end

  private

  def authorized_ku_staff?
    user.is?('Admin', 'Sales')
  end

  def requester?
    return false if record.user_id.nil?

    user.id == record.user_id
  end

  def requester_manager?
    return false if record.user.nil?

    requester_org_admin? || requester_school_manager?
  end

  def requester_org_admin?
    user.is?('OrgAdmin') && user.organisation_id == record.user.organisation_id
  end

  def requester_school_manager?
    user.is?('SchoolManager') &&
      user.schools.ids.intersect?(record.user.schools.ids)
  end
end
