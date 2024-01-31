# frozen_string_literal: true

class AdminPolicy < ApplicationPolicy
  def show?
    self?
  end

  def edit?
    self?
  end

  def update?
    self?
  end

  private

  def self?
    user.is?('Admin') && user.id == record.id
  end
end
