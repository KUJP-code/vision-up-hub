class TutorialsController < ApplicationController
  before_action :set_tutorial, only: :destroy

  def index
    @sections = PdfTutorial.sections.keys.map { |key| [key.titleize, key] }

    if params[:query].present?
      @video_tutorials = VideoTutorial.where('title ILIKE ?', "%#{params[:query]}%")
      @pdf_tutorials = PdfTutorial.where('title ILIKE ?', "%#{params[:query]}%")
      @faq_tutorials = FaqTutorial.where('question ILIKE ?', "%#{params[:query]}%")
    else
      @video_tutorials = VideoTutorial.all
      @pdf_tutorials = PdfTutorial.all
      @faq_tutorials = FaqTutorial.all
    end
  end

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

  def create
    @tutorial = case params[:type]
                when 'PDF'
                  PdfTutorial.new(tutorial_params(:pdf_tutorial))
                when 'Video'
                  VideoTutorial.new(tutorial_params(:video_tutorial))
                when 'FAQ'
                  FaqTutorial.new(tutorial_params(:faq_tutorial).merge(section: 'faq'))
                else
                  redirect_to new_tutorial_path, alert: 'Invalid tutorial type'
                  return
                end

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

  def tutorial_params(model)
    params.require(model).permit(:title, :video_path, :file_path, :section, :question, :answer)
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
    else
      nil
    end
  end
end
