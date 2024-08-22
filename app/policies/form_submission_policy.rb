# frozen_string_literal: true

class FormSubmissionPolicy < ApplicationPolicy
  def show?
    user.is?('Admin') || submission_org_admin? || sm_who_created? || parent_who_completed?
  end

  def new?
    user.is?('Admin') || authorized_org_staff?
  end

  def edit?
    user.is?('Admin') || submission_org_admin? || sm_who_created? || parent_who_completed?
  end

  def update?
    user.is?('Admin') || submission_org_admin? || sm_who_created? || parent_who_completed?
  end

  def create?
    user.is?('Admin') || authorized_org_staff?
  end

  def destroy?
    user.is?('Admin') || submission_org_admin? || sm_who_created?
  end

  class Scope < Scope
    def resolve
      case user.type
      when 'Admin'
        scope.all
      when 'OrgAdmin'
        scope.where(organisation_id: user.organisation_id)
      when 'SchoolManager', 'Parent'
        user.form_submissions
      else
        scope.none
      end
    end
  end

  private

  def authorized_org_staff?
    user.is?('OrgAdmin', 'SchoolManager') && user.organisation_id == record.organisation_id
  end

  def submission_org_admin?
    user.is?('OrgAdmin') && user.organisation_id == record.organisation_id
  end

  def sm_who_created?
    user.is?('SchoolManager') && user.id == record.staff_id
  end

  def parent_who_completed?
    user.is?('Parent') && user.id == record.parent_id
  end
end
