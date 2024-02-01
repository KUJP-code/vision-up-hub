# frozen_string_literal: true

class OrgAdminPolicy < ApplicationPolicy
  def show?
    user.is?('Admin', 'Sales', 'OrgAdmin')
  end

  def new?
    user.is?('Admin', 'Sales')
  end

  def edit?
    user.is?('Admin', 'Sales') || managing_self?
  end

  def update?
    user.is?('Admin', 'Sales') || managing_self?
  end

  def create?
    user.is?('Admin', 'Sales')
  end

  def destroy?
    user.is?('Admin', 'Sales')
  end

  private

  def managing_self?
    user.is?('OrgAdmin') && record.id == user.id
  end
end
