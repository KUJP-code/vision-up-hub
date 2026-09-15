# frozen_string_literal: true

class ScreenMirroringTestsController < ApplicationController
  def show
    render :reference if params[:reference] == '2.7.9.1'
  end
end
