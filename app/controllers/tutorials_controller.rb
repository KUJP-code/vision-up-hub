# frozen_string_literal: true

class TutorialsController < ApplicationController
  # render index page for listing tutorials
  def index
    @tutorials = Tutorial.all
  end

  # Display the new tutorial form
  def new
    @tutorial = Tutorial.new
  end

  # make a new tutorial and redirect
  def create
    @tutorial = Tutorial.new(tutorial_params)
    if @tutorial.save
      redirect_to tutorials_path, notice: 'Tutorial was successfully created.'
    else
      render :new
    end
  end

  def destroy
    @tutorial = Tutorial.find(params[:id])
    @tutorial.destroy
    redirect_to tutorials_path, notice: 'Tutorial was successfully deleted.'
  end

  private

  def tutorial_params
    params.require(:tutorial).permit(:title, :content, :tutorial_type)
  end
end
