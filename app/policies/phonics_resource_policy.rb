# frozen_string_literal: true

class PhonicsResourcePolicy < ApplicationPolicy
  def destroy?
    user.is?('Admin')
  end
end
