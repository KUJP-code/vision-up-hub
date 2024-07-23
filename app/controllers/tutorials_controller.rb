# frozen_string_literal: true

class TutorialsController < ApplicationController
  include TutorialHelper

  before_action :set_tutorial, only: %i[destroy show edit update]
  before_action :set_type, only: %i[new create edit update]
  before_action :set_categories, only: %i[new create edit update]

  # Fetch categories and tutorials grouped by type for index page
  def index
    @categories = TutorialCategory.all
    @tutorials = {
      pdf: PdfTutorial.includes(file_attachment: :blob),
      video: VideoTutorial.all,
      faq: FaqTutorial.all
    }
  end

  # Renders video modal
  def show
    return unless @tutorial.is_a?(VideoTutorial)

    render partial: 'video_modal', locals: { tutorial: @tutorial }
  end

  # Initialize new object based on type
  def new
    @tutorial = tutorial_class.new
  end

  def edit; end

  def create
    @tutorial = tutorial_class.new(tutorial_params)

    if @tutorial.save
      redirect_to tutorials_path, notice: "#{params[:type]} tutorial was successfully created."
    else
      render :new, status: :unprocessable_entity, alert: "#{params[:type]} tutorial could not be created."
    end
  end

  def update
    if @tutorial.update(tutorial_params)
      redirect_to tutorials_path, notice: "#{params[:type]} tutorial was successfully updated."
    else
      render :edit, status: :unprocessable_entity, alert: "#{params[:type]} tutorial could not be updated."
    end
  end

  # Deletes + purges file if it has one
  def destroy
    if @tutorial.destroy
      redirect_to tutorials_path, notice: 'Tutorial was successfully deleted.'
    else
      redirect_to tutorials_path, alert: 'There was an error deleting this tutorial.'
    end
  end

  private

  # Permits parameters depending on type, calls helper to convert video link in the case of video here
  def tutorial_params
    case params[:type]
    when 'PDF'
      params.require(:pdf_tutorial).permit(:title, :tutorial_category_id, :file)
    when 'Video'
      params.require(:video_tutorial).permit(:title, :tutorial_category_id, :video_path).tap do |video_params|
        video_params[:video_path] = convert_video_link(video_params[:video_path])
      end
    when 'FAQ'
      params.require(:faq_tutorial).permit(:question, :answer, :tutorial_category_id)
    else
      {}
    end
  end

  def set_categories
    @categories = TutorialCategory.pluck(:title, :id)
  end

  def set_type
    @type = params[:type]
  end

  def set_tutorial
    @tutorial = tutorial_class.find(params[:id])
  end

  def tutorial_class
    case params[:type]
    when 'PDF'
      PdfTutorial
    when 'Video'
      VideoTutorial
    when 'FAQ'
      FaqTutorial
    end
  end
end
