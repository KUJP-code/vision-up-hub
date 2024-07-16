# frozen_string_literal: true

class TutorialsController < ApplicationController
  include TutorialHelper

  before_action :set_tutorial, only: %i[destroy video_modal edit update]
  before_action :set_categories, only: %i[new create edit update]
  before_action :set_type, only: %i[new create edit update]

  # Fetch categories and tutorials grouped by type for index page
  def index
    @categories = PdfTutorial.categories.keys.map { |key| [key.titleize, key] }
    @tutorials = {
      pdf: PdfTutorial.includes(file_attachment: :blob),
      video: VideoTutorial.all,
      faq: FaqTutorial.all
    }
  end

  # Initialize new object based on type
  def new
    @tutorial = tutorial_class.new
  end

  # Prepares edit form for tutorial
  def edit; end

  # Creation of new tutorial with validation and saving
  def create
    @tutorial = tutorial_class.new(tutorial_params)

    if valid_tutorial? && @tutorial.save
      redirect_to tutorials_path, notice: "#{params[:type]} tutorial was successfully created."
    else
      render :new, status: :unprocessable_entity, alert: "#{params[:type]} tutorial could not be created."
    end
  end

  # Updating existing tutorial with validations from valid_tutorial
  def update
    if valid_tutorial? && @tutorial.update(tutorial_params)
      redirect_to tutorials_path, notice: "#{params[:type]} tutorial was successfully updated."
    else
      render :edit, status: :unprocessable_entity, alert: "#{params[:type]} tutorial could not be updated."
    end
  end

  # Deletes + purges file if it has one
  def destroy
    @tutorial.file.purge if @tutorial.file.attached?
    if @tutorial.destroy
      redirect_to tutorials_path, notice: 'Tutorial was successfully deleted.'
    else
      redirect_to tutorials_path, alert: 'There was an error deleting this tutorial.'
    end
  end

  # Renders video modal
  def video_modal
    render partial: 'video_modal', locals: { tutorial: @tutorial }
  end

  private

  # Permits parameters depending on type, calls helper to convert video link in the case of video here
  def tutorial_params
    case params[:type]
    when 'PDF'
      params.require(:pdf_tutorial).permit(:title, :category, :file)
    when 'Video'
      params.require(:video_tutorial).permit(:title, :category, :video_path).tap do |video_params|
        if valid_video_link?(video_params[:video_path])
          video_params[:video_path] = convert_video_link(video_params[:video_path])
        end
      end
    when 'FAQ'
      params.require(:faq_tutorial).permit(:question, :answer)
    else
      {}
    end
  end

  # checks which tutorial it is and calls appropriate valitions
  def valid_tutorial?
    case params[:type]
    when 'PDF'
      validate_pdf
    when 'Video'
      validate_video
    else
      true
    end
  end

  # Both validate pdf and video call helper methods to check links/file
  def validate_pdf
    return true if params[:pdf_tutorial][:file].blank?

    valid_file?(params[:pdf_tutorial][:file]).tap do |valid|
      flash[:alert] = 'Invalid file type. Please upload a PDF, PPT, PPTX, XLS, XLSX, JPG, or PNG.' unless valid
    end
  end

  def validate_video
    return true if params[:video_tutorial][:video_path].blank?

    valid_video_link?(params[:video_tutorial][:video_path]).tap do |valid|
      flash[:alert] = 'Invalid video link. Please use a Vimeo or YouTube link.' unless valid
    end
  end

  def set_categories
    @categories = PdfTutorial.categories.keys.map { |key| [key.titleize, key] } if %w[PDF Video].include?(params[:type])
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
