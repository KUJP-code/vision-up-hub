# frozen_string_literal: true

class TutorialsController < ApplicationController
  before_action :set_tutorial, only: :destroy

  # index to list all tutorials
  def index
    @sections = PdfTutorial.sections.keys.map { |key| [key.titleize, key] }
    @video_tutorials = VideoTutorial.all
    @pdf_tutorials = PdfTutorial.all
    @faq_tutorials = FaqTutorial.all
  end

  # initialize new tutorial object based on type parameter
  def new
    @type = params[:type]
    @tutorial = case @type
                when 'PDF'
                  PdfTutorial.new
                when 'Video'
                  VideoTutorial.new
                when 'FAQ'
                  FaqTutorial.new
                else
                  redirect_to tutorials_path, alert: 'Invalid tutorial type'
                  return
                end
  end


  # create action for new tutorial
  def create
    Rails.logger.debug("Params: #{params.inspect}")
    # initialize a new object based on type
    @tutorial = case params[:type]
                when 'PDF'
                  PdfTutorial.new(pdf_tutorial_params)
                when 'Video'
                  VideoTutorial.new(video_tutorial_params)
                when 'FAQ'
                  FaqTutorial.new(faq_tutorial_params.merge(section: 'faq'))
                else
                  redirect_to new_tutorial_path, alert: 'Invalid tutorial type'
                  return
                end

    #save object and redirect or rerender based on result
    if @tutorial.save
      redirect_to tutorials_path, notice: "#{params[:type]} tutorial was successfully created."
    else
      @type = params[:type]
      render :new
    end
  end

  def destroy
    @tutorial.destroy
    redirect_to tutorials_path, notice: 'Tutorial was successfully deleted.'
  end

  private

  # strong parameters for each tutorial
  def pdf_tutorial_params
    params.require(:pdf_tutorial).permit(:title, :section, :file)
  end

  def video_tutorial_params
    params.require(:video_tutorial).permit(:title, :section, :video_path)
  end

  def faq_tutorial_params
    params.require(:faq_tutorial).permit(:question, :answer, :section)
  end

  # set tutorial object based on type
  def set_tutorial
    @tutorial = tutorial_class.find(params[:id])
  end

  # determine the class based on the type parameter
  def tutorial_class
    case params[:type]
    when 'PDF'
      PdfTutorial
    when 'Video'
      VideoTutorial
    when 'FAQ'
      FaqTutorial
    else
      nil
    end
  end
end
