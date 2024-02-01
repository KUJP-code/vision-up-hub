# frozen_string_literal: true

class SchoolManagerPolicy < ApplicationPolicy
  def show?
    user.is?('Admin', 'Sales') || managing_self? || admin_of_org?
  end

  def new?
    user.is?('Admin', 'Sales') || admin_of_org?
  end

  def edit?
    user.is?('Admin', 'Sales') || managing_self? || admin_of_org?
  end

  def update?
    user.is?('Admin', 'Sales') || managing_self? || admin_of_org?
  end

  def create?
    user.is?('Admin', 'Sales') || admin_of_org?
  end

  def destroy?
    user.is?('Admin', 'Sales') || admin_of_org?
  end

  private

  def admin_of_org?
    user.is?('OrgAdmin') && record.organisation_id == user.organisation_id
  end

  def managing_self?
    user.is?('SchoolManager') && record.id == user.id
  end
end
