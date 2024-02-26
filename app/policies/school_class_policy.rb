# frozen_string_literal: true

class SchoolClassPolicy < ApplicationPolicy
  def index?
    user.is?('Admin', 'OrgAdmin', 'SchoolManager', 'Teacher')
  end

  def show?
    user.is?('Admin') || authorized_class_org_user?
  end

  def new?
    user.is?('Admin', 'OrgAdmin', 'SchoolManager')
  end

  def edit?
    user.is?('Admin') || authorized_class_org_user?
  end

  def update?
    user.is?('Admin') || authorized_class_org_user?
  end

  def create?
    user.is?('Admin') || authorized_class_org_manager?
  end

  def destroy?
    user.is?('Admin') || authorized_class_org_manager?
  end

  class Scope < Scope
    def resolve
      case user.type
      when 'Admin'
        scope.all
      when 'OrgAdmin'
        user.organisation.classes
      when 'SchoolManager', 'Teacher'
        user.classes
      else
        scope.none
      end
    end
  end

  private

  def authorized_class_org_user?
    return false if different_org?

    user.is?('OrgAdmin') || class_school_manager? || class_teacher?
  end

  def authorized_class_org_manager?
    return false if different_org?

    user.is?('OrgAdmin') || class_school_manager?
  end

  def different_org?
    user.organisation_id != record.organisation_id
  end

  def class_school_manager?
    user.is?('SchoolManager') && user.schools.ids.include?(record.school_id)
  end

  def class_teacher?
    user.is?('Teacher') && user.classes.ids.include?(record.id)
  end
end
