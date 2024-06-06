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

  def ku_staff?
    user.is?('Admin', 'Sales', 'Writer')
  end

  def managing_self?
    user.is?('Teacher') && record.id == user.id
  end

  def org_staff?
    (user.is?('OrgAdmin') && record.organisation_id == user.organisation_id) ||
      managed_school_or_nil?
  end

  def managed_school_or_nil?
    user.is?('SchoolManager') &&
      (record.schools.empty? || user.schools.ids.intersect?(record.schools.ids))
  end
end
