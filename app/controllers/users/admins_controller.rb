# frozen_string_literal: true

class AdminsController < UsersController
  def show
    redirect_to courses_path
  end
end
