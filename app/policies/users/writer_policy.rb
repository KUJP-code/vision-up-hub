# frozen_string_literal: true

class WriterPolicy < ApplicationPolicy
  def index?
    user.is?('Admin')
  end

  def show?
    user.is?('Admin') || managing_self?
  end

  def new?
    user.is?('Admin')
  end

  def edit?
    user.is?('Admin') || managing_self?
  end

  def update?
    user.is?('Admin') || managing_self?
  end

  def create?
    user.is?('Admin')
  end

  def destroy?
    user.is?('Admin')
  end

  class Scope < Scope
    def resolve
      authorized_ku_staff? ? scope.all : scope.none
    end

    def authorized_ku_staff?
      user.is?('Admin', 'Writer')
    end
  end

  private

  def managing_self?
    user.is?('Writer') && record.id == user.id
  end
end
