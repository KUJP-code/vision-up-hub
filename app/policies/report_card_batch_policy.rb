# frozen_string_literal: true

class ReportCardBatchPolicy < ApplicationPolicy
  def index?
    user.is?('Admin', 'OrgAdmin', 'SchoolManager')
  end

  def show?
    can_access_school?
  end

  def create?
    can_access_school?
  end

  def update?
    can_access_school?
  end

  def regenerate?
    can_access_school?
  end

  def destroy?  = user.is?('Admin')

  class Scope < Scope
    def resolve
      if user.is?('Admin')
        scope.joins(:school).where(schools: { organisation_id: user.organisation_id })
      elsif user.is?('OrgAdmin', 'SchoolManager')
        scope.where(school_id: user.school_ids)
      else
        scope.none
      end
    end
  end

  private

  def can_access_school?
    return false unless user.is?('Admin', 'OrgAdmin', 'SchoolManager')
    return user.organisation_id == record.school&.organisation_id if user.is?('Admin')

    user.school_ids.include?(record.school_id)
  end
end
