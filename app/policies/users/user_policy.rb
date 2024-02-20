# frozen_string_literal: true

class UserPolicy < ApplicationPolicy
  def index?
    authorized_ku_staff? || authorized_org_staff?
  end

  class Scope < Scope
    def resolve
      case user.type
      when 'Admin'
        scope.all
      when 'Sales'
        scope.where(type: user.class::VISIBLE_TYPES)
      when 'OrgAdmin'
        scope.where(organisation_id: user.organisation_id)
      when 'SchoolManager'
        user.teachers
      else
        scope.none
      end
    end
  end

  private

  def authorized_ku_staff?
    user.is?('Admin', 'Sales')
  end

  def authorized_org_staff?
    user.is?('OrgAdmin') && record.organisation_id == user.organisation_id
  end
end
