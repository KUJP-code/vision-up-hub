# frozen_string_literal: true

class PearsonUploadPolicy < ApplicationPolicy
  def index?
    false
  end

  def show?
    user.is?('Admin', 'OrgAdmin')
  end

  def new?
    user.is?('Admin', 'OrgAdmin')
  end

  def edit?
    false
  end

  def update?
    false
  end

  def create?
    user.is?('Admin', 'OrgAdmin')
  end

  def destroy?
    false
  end
end
