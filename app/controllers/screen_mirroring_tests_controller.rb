# frozen_string_literal: true

class ScreenMirroringTestsController < ApplicationController
  layout -> { params[:reference] == '2.7.9.1' ? 'application' : 'lesson_prototype' }

  def show
    if params[:reference] == '2.7.9.1'
      render :reference
    else
      @lesson_content = AiSenseiContent.week_one
    end
  end
end
