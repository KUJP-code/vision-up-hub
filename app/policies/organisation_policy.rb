# frozen_string_literal: true

class OrganisationPolicy < ApplicationPolicy
  def index?
    authorized_ku_staff?
  end

  def show?
    authorized_ku_staff? || user.organisation_id == record.id
  end

  def new?
    authorized_ku_staff?
  end

  def edit?
    authorized_ku_staff? || admin_of_org?
  end

  def create?
    authorized_ku_staff?
  end

  def update?
    authorized_ku_staff? || admin_of_org?
  end

  class Scope < Scope
    def resolve
      if authorized_ku_staff?
        scope.all

      elsif user.is?('OrgAdmin')
        scope.where(id: user.organisation_id)

      else
        scope.none
      end
    end

    def authorized_ku_staff?
      user.is?('Admin', 'Sales')
    end
  end

  private

  def admin_of_org?
    user.is?('OrgAdmin') && record.id == user.organisation_id
  end

  def authorized_ku_staff?
    user.is?('Admin', 'Sales')
  end
end
