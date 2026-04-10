# frozen_string_literal: true

class OrganisationPolicy < ApplicationPolicy
  def index?
    authorized_ku_staff?
  end

  def show?
    authorized_ku_staff? || user.organisation_id == record.id
  end

  def new?
    managing_ku_staff?
  end

  def edit?
    managing_ku_staff? || admin_of_org?
  end

  def create?
    managing_ku_staff?
  end

  def update?
    managing_ku_staff? || admin_of_org?
  end

  class Scope < Scope
    def resolve
      if authorized_ku_staff?
        scope.all
      else
        scope.where(id: user.organisation_id)
      end
    end

    def authorized_ku_staff?
      user.is?('Admin', 'Sales', 'Writer')
    end
  end

  private

  def admin_of_org?
    user.is?('OrgAdmin') && record.id == user.organisation_id
  end

  def authorized_ku_staff?
    user.is?('Admin', 'Sales', 'Writer')
  end

  def managing_ku_staff?
    user.is?('Admin', 'Sales')
  end
end
