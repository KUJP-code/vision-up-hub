# frozen_string_literal: true

class MonthlyMaterialsPolicy < ApplicationPolicy
  def index?
    user.is?('Admin', 'Writer')
  end
end
