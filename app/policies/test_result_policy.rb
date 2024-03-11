# frozen_string_literal: true

class TestResultPolicy < ApplicationPolicy
  def index?
    user.is?('Admin') || org_results?
  end

  def show?
    false
  end

  def new?
    false
  end

  def edit?
    false
  end

  def update?
    user.is?('Admin') || org_results?
  end

  def create?
    user.is?('Admin') || org_results?
  end

  def destroy?
    false
  end

  class Scope < Scope
    def resolve
      case user.type
      when 'Admin'
        scope.all
      when 'OrgAdmin', 'SchoolManager', 'Teacher'
        user.test_results
      else
        scope.none
      end
    end
  end

  private

  def org_results?
    org_admin_results? || school_manager_results? || teacher_results?
  end

  def org_admin_results?
    return false if user.organisation_id.nil?

    user.is?('OrgAdmin') && user.organisation_id == record.organisation_id
  end

  def school_manager_results?
    user.is?('SchoolManager') && user.students.ids.include?(record.student_id)
  end

  def teacher_results?
    user.is?('Teacher') && user.students.ids.include?(record.student_id)
  end
end
