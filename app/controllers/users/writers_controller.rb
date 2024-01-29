# frozen_string_literal: true

class WritersController < ApplicationController
  def show
    redirect_to courses_path
  end
end
