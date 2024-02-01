# frozen_string_literal: true

class TeacherPolicy < ApplicationPolicy
  def show?
    ku_staff? || managing_self? || org_staff?
  end

  def new?
    user.is?('Admin', 'Sales') || org_staff?
  end

  def edit?
    user.is?('Admin', 'Sales') || managing_self? || org_staff?
  end

  def update?
    user.is?('Admin', 'Sales') || managing_self? || org_staff?
  end

  def create?
    user.is?('Admin', 'Sales') || org_staff?
  end

  def destroy?
    user.is?('Admin', 'Sales') || org_staff?
  end

  private

  def managing_self?
    user.is?('Teacher') && record.id == user.id
  end

  def org_staff?
    (user.is?('OrgAdmin') && record.organisation_id == user.organisation_id) ||
      (user.is?('SchoolManager') && user.schools.ids.include?(record.school_id))
  end

  def ku_staff?
    user.is?('Admin', 'Sales')
  end
end
