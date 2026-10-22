# frozen_string_literal: true

class ScreenMirroringTestsController < ApplicationController
  layout -> { params[:reference] == '2.7.9.1' ? 'application' : 'lesson_prototype' }

  def show
    render :reference if params[:reference] == '2.7.9.1'
  end
end
