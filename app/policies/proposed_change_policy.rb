# frozen_string_literal: true

class ProposedChangePolicy < ApplicationPolicy
  def index?
    false
  end

  def show?
    false
  end

  def new?
    false
  end

  def edit?
    false
  end

  def create?
    false
  end

  def update?
    user.is?('Admin')
  end

  def destroy?
    user.is?('Admin')
  end
end
