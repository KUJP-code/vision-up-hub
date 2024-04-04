# frozen_string_literal: true

class ProposalPolicy < ApplicationPolicy
  def show?
    user.is?('Admin')
  end

  def new?
    false
  end

  def edit?
    false
  end

  def update?
    user.is?('Admin')
  end

  def create?
    false
  end

  def destroy?
    false
  end
end
