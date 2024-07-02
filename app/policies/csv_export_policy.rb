# frozen_string_literal: true

class CsvExportPolicy < ApplicationPolicy
  def index?
    user.is?('Admin')
  end

  def show?
    user.is?('Admin')
  end

  def new?
    user.is?('Admin')
  end

  def create?
    user.is?('Admin')
  end
end
