# frozen_string_literal: true

class SalesPolicy < ApplicationPolicy
  def index?
    user.is?('Admin', 'Sales')
  end

  def show?
    user.is?('Admin', 'Sales')
  end

  def new?
    user.is?('Admin', 'Sales')
  end

  def edit?
    user.is?('Admin') || managing_self?
  end

  def update?
    user.is?('Admin') || managing_self?
  end

  def create?
    user.is?('Admin', 'Sales')
  end

  def destroy?
    user.is?('Admin')
  end

  private

  def managing_self?
    user.is?('Sales') && record.id == user.id
  end
end
