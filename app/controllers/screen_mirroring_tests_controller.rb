# frozen_string_literal: true

class ScreenMirroringTestsController < ApplicationController
  layout -> { %w[2.7.9.1 2.8.3.1].include?(params[:reference]) ? 'application' : 'lesson_prototype' }

  def show
    case params[:reference]
    when '2.7.9.1'
      render :reference
    when '2.8.3.1'
      render :reference_2831
    else
      @lesson_content = AiSenseiContent.week_one
    end
  end
end
