# frozen_string_literal: true

class CourseLessonUploadPolicy < ApplicationPolicy
  def index?
    false
  end

  def show?
    user.is?('Admin')
  end

  def new?
    user.is?('Admin')
  end

  def edit?
    false
  end

  def update?
    false
  end

  def create?
    user.is?('Admin')
  end

  def destroy?
    false
  end
end
