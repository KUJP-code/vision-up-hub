# frozen_string_literal: true

class CurriculumsController < ApplicationController
  def show
    redirect_to courses_path
  end
end
