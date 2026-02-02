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
    user.is?('Admin') || org_staff?
  end

  private

  def ku_staff?
    user.is?('Admin', 'Sales', 'Writer')
  end

  def managing_self?
    user.is?('Teacher') && record.id == user.id
  end

  def org_staff?
    return true if user.is?('OrgAdmin') && record.organisation_id == user.organisation_id
    return false unless user.is?('SchoolManager')

    managed_organisation? && managed_school?
  end

  def managed_school?
    return false unless user.is?('SchoolManager')
    return true if record_school_ids.empty?

    user_school_ids.intersect?(record_school_ids)
  end

  def managed_organisation?
    return user.schools.any? { |school| school.organisation_id == record.organisation_id } if user.new_record?

    user.schools.where(organisation_id: record.organisation_id).exists?
  end

  def user_school_ids
    return user.schools.map(&:id) if user.new_record?

    user.school_ids
  end

  def record_school_ids
    record.school_ids.presence || record.school_teachers.map(&:school_id).compact
  end
end
