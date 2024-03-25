# frozen_string_literal: true

class StudentSearchesController < ApplicationController
  def show; end

  def create
    @results = Student.where(search_params)
  end

  private

  def search_params
    if current_user.is?('Parent')
      params.require(:search).permit(:level, :student_id)
    else
      params.require(:search).permit(:level, :name, :school_id, :student_id)
    end
  end
end
