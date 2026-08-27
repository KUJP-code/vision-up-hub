# frozen_string_literal: true

class TestPolicy < ApplicationPolicy
  def index?
    user.is?('Admin')
  end

  def show?
    user.is?('Admin')
  end

  def new?
    user.is?('Admin')
  end

  def edit?
    user.is?('Admin')
  end

  def update?
    user.is?('Admin')
  end

  def create?
    user.is?('Admin')
  end

  def destroy?
    user.is?('Admin')
  end

  class Scope < Scope
    def resolve
      case user.type
      when 'Admin'
        scope.all
      when 'Teacher'
        user.available_tests(Time.zone.today, since: 6.months.ago.to_date)
      when 'OrgAdmin', 'SchoolManager'
        user.available_tests
      else
        scope.none
      end
    end
  end
end
