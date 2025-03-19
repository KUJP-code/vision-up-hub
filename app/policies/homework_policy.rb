# frozen_string_literal: true

class HomeworkPolicy < ApplicationPolicy
  def index?
    user.all
  end

  def new?
    user.is?('Admin', 'Writer')
  end

  def create?
    user.is?('Admin', 'Writer')
  end

  def destroy?
    user.is?('Admin')
  end
end

class Scope < scope
  def resolve
    user.is?('Admin') ? scope.all : scope.none
    case user.type
    when 'Admin'
      scope.all
    else filter_by_week_range(scope)
  end

  private

  def filter_by_week_range
    current_week = Date.current.cweek
    min_week = [current_week - 2, 1].max
    max_week = [current_week + 2, 52].min

    scope.where(week: min_week..max_week)
  end
end