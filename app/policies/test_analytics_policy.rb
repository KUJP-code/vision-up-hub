# frozen_string_literal: true

class TestAnalyticsPolicy < ApplicationPolicy
  def index?
    user.is?('Admin')
  end

  def export?
    index?
  end
end
