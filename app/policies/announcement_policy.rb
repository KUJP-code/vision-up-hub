# frozen_string_literal: true

class AnnouncementPolicy < ApplicationPolicy
  def show?
    user.is?('Admin') || announcement_org_admin?
  end

  def new?
    user.is?('Admin') || announcement_org_admin?
  end

  def edit?
    user.is?('Admin') || announcement_org_admin?
  end

  def update?
    user.is?('Admin') || announcement_org_admin?
  end

  def create?
    user.is?('Admin') || announcement_org_admin?
  end

  def destroy?
    user.is?('Admin') || announcement_org_admin?
  end

  class Scope < Scope
    def resolve
      case user.type
      when 'Admin'
        scope.all
      when 'OrgAdmin'
        scope.where(organisation_id: [user.organisation_id, nil])
      when 'Writer', 'Sales', 'SchoolManager', 'Teacher', 'Parent'
        scope.where(organisation_id: [user.organisation_id, nil], role: [user.type, nil],
                    start_date: ..Time.zone.today, finish_date: Time.zone.today..)
      end
    end
  end

  private

  def announcement_org_admin?
    user.is?('OrgAdmin') && user.organisation_id == record.organisation_id
  end
end
