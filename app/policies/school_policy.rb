# frozen_string_literal: true

class SchoolPolicy < ApplicationPolicy
  def show?
    authorized_ku_staff? || admin_of_org? || manager_of_school?
  end

  def new?
    user.is?('Admin', 'Sales', 'OrgAdmin')
  end

  def edit?
    authorized_ku_staff? || admin_of_org? || manager_of_school?
  end

  def update?
    authorized_ku_staff? || admin_of_org? || manager_of_school?
  end

  def create?
    authorized_ku_staff? || admin_of_org?
  end

  def destroy?
    authorized_ku_staff? || admin_of_org?
  end

  class Scope < Scope
    def resolve
      case user.type
      when 'Admin', 'Sales'
        scope.all
      when 'OrgAdmin'
        user.organisation.schools
      when 'SchoolManager'
        user.schools
      else
        scope.none
      end
    end
  end

  private

  def admin_of_org?
    user.is?('OrgAdmin') && record.organisation_id == user.organisation_id
  end

  def authorized_ku_staff?
    user.is?('Admin', 'Sales')
  end

  def manager_of_school?
    user.is?('SchoolManager') && user.schools.ids.include?(record.id)
  end
end
