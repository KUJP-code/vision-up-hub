# frozen_string_literal: true

class LessonUsesPolicy < ApplicationPolicy
  def index?
    user.is?('Admin', 'Writer')
  end
end
