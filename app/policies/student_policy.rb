# frozen_string_literal: true

class StudentPolicy < ApplicationPolicy
  def index?
    user.is?('Admin', 'OrgAdmin', 'SchoolManager', 'Teacher')
  end

  def show?
    user.is?('Admin') || authorized_student_org_user? || parent?
  end

  def new?
    user.is?('Admin', 'OrgAdmin', 'Parent', 'SchoolManager', 'Teacher')
  end

  def edit?
    user.is?('Admin') || authorized_student_org_user? || parent?
  end

  def update?
    user.is?('Admin') || authorized_student_org_user? || parent?
  end

  def create?
    user.is?('Admin') || authorized_student_org_user? || parent?
  end

  def destroy?
    user.is?('Admin') || authorized_student_org_manager?
  end

  def icon_chooser?
    user.is?('Admin') || authorized_student_org_user? || parent?
  end

  class Scope < Scope
    def resolve
      case user.type
      when 'Admin'
        scope.all
      when 'OrgAdmin'
        scope.where(organisation_id: user.organisation_id)
      when 'SchoolManager', 'Teacher'
        user.students
      when 'Parent'
        user.children
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

  def parent?
    return false if record.parent_id.nil?

    user.is?('Parent') && record.parent_id == user.id
  end

  def student_school_manager?
    user.is?('SchoolManager') && user.schools.ids.include?(record.school_id)
  end

  def student_teacher?
    user.is?('Teacher') && user.students.ids.include?(record.id)
  end
end
