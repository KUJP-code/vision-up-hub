# frozen_string_literal: true

class ProposedChangePolicy < ApplicationPolicy
  def update?
    user.is?('Admin')
  end

  def destroy?
    user.is?('Admin')
  end
end
