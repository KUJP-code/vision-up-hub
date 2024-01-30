# frozen_string_literal: true

class SalesController < UsersController
  def show
    redirect_to courses_path
  end
end
