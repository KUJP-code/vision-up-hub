# frozen_string_literal: true

class StudentPolicy < ApplicationPolicy
  def index?
    user.is?('Admin', 'OrgAdmin', 'SchoolManager', 'Teacher')
  end

  def show?
    user.is?('Admin') || authorized_student_org_user?
  end

  def new?
    user.is?('Admin', 'OrgAdmin', 'SchoolManager', 'Teacher')
  end

  def edit?
    user.is?('Admin') || authorized_student_org_user?
  end

  def update?
    user.is?('Admin') || authorized_student_org_user?
  end

  def create?
    user.is?('Admin') || authorized_student_org_user?
  end

  def destroy?
    user.is?('Admin') || authorized_student_org_manager?
  end

  class Scope < Scope
    def resolve
      case user.type
      when 'Admin'
        scope.all
      when 'OrgAdmin'
        user.organisation.students
      when 'SchoolManager', 'Teacher'
        user.students
      else
        scope.none
      end
    end
  end

  private

  def authorized_student_org_user?
    return false if different_org?

    user.is?('OrgAdmin') || student_school_manager? || student_teacher?
  end

  def authorized_student_org_manager?
    return false if different_org?

    user.is?('OrgAdmin') || student_school_manager?
  end

  def different_org?
    user.organisation_id != record.organisation_id
  end

  def student_school_manager?
    user.is?('SchoolManager') && user.schools.ids.include?(record.school_id)
  end

  def student_teacher?
    user.is?('Teacher') && user.students.ids.include?(record.id)
  end
end
