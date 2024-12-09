# frozen_string_literal: true

class InvoicePolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      user.is?('Admin') ? scope.all : scope.none
    end
  end

  def index?
    admin_only
  end

  def create?
    admin_only
  end

  def destroy?
    admin_only
  end

  def show?
    admin_only
  end

  def edit?
    admin_only
  end

  def update?
    admin_only
  end

  def pdf?
    admin_only
  end

  private

  def admin_only
    user.is?('Admin')
  end
end
