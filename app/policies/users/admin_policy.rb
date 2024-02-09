# frozen_string_literal: true

class AdminPolicy < ApplicationPolicy
  def show?
    user.is?('Admin')
  end

  def edit?
    self?
  end

  def update?
    self?
  end

  def reassign_editor?
    user.is?('Admin')
  end

  private

  def self?
    user.is?('Admin') && user.id == record.id
  end
end
