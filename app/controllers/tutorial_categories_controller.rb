# frozen_string_literal: true

class TutorialCategoriesController < ApplicationController
  before_action :set_tutorial_category, only: %i[destroy show edit update]
  def index
    @tutorial_categories = TutorialCategory.all
  end

  def show
    @tutorials = {
      FAQ: @tutorial_category.faq_tutorials.order(:question),
      PDF: @tutorial_category.pdf_tutorials.order(:title),
      Video: @tutorial_category.video_tutorials.order(:title)
    }
  end

  def new
    @tutorial_category = TutorialCategory.new
  end

  def edit; end

  def create
    @tutorial_category = TutorialCategory.new(tutorial_category_params)

    if @tutorial_category.save
      redirect_to tutorials_path,
                  notice: 'Category was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @tutorial_category.update(tutorial_category_params)
      redirect_to tutorials_path, notice: 'Category was successfully updated.'
    else
      render :edit,
             status: :unprocessable_entity
    end
  end

  def destroy
    @tutorial_category.destroy
    redirect_to tutorials_path,
                notice: 'Category was successfully deleted.'
  end

  private

  def tutorial_category_params
    params.require(:tutorial_category).permit(:svg, :title)
  end

  def set_tutorial_category
    @tutorial_category = TutorialCategory.find(params[:id])
  end
end
