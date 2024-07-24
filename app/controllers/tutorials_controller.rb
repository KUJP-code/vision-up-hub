# frozen_string_literal: true

class TutorialsController < ApplicationController
  before_action :set_type, except: %i[index]
  before_action :set_tutorial, except: %i[index create new]
  before_action :set_categories, except: %i[index destroy]

  def index
    @categories = TutorialCategory.all
    @tutorials = {
      pdf: PdfTutorial.includes(file_attachment: :blob),
      video: VideoTutorial.all,
      faq: FaqTutorial.all
    }
  end

  def show
    return unless @tutorial.is_a?(VideoTutorial)

    render partial: 'video_modal', locals: { tutorial: @tutorial }
  end

  def new
    @tutorial = tutorial_class.new
  end

  def edit; end

  def create
    @tutorial = tutorial_class.new(tutorial_params)

    if @tutorial.save
      redirect_to tutorials_path,
                  notice: "#{@type} tutorial was successfully created."
    else
      render :new,
             status: :unprocessable_entity,
             alert: "#{@type} tutorial could not be created."
    end
  end

  def update
    if @tutorial.update(tutorial_params)
      redirect_to tutorials_path,
                  notice: "#{@type} tutorial was successfully updated."
    else
      render :edit,
             status: :unprocessable_entity,
             alert: "#{@type} tutorial could not be updated."
    end
  end

  def destroy
    if @tutorial.destroy
      redirect_to tutorials_path,
                  notice: 'Tutorial was successfully deleted.'
    else
      redirect_to tutorials_path,
                  alert: 'There was an error deleting this tutorial.'
    end
  end

  private

  def tutorial_params
    case @type
    when 'PDF'
      params.require(:pdf_tutorial).permit(
        :title, :tutorial_category_id, :file
      )
    when 'Video'
      params.require(:video_tutorial).permit(
        :title, :tutorial_category_id, :video_path
      )
    when 'FAQ'
      params.require(:faq_tutorial).permit(
        :question, :answer, :tutorial_category_id
      )
    else
      {}
    end
  end

  def set_categories
    @categories = TutorialCategory.pluck(:title, :id)
                                  .map { |title, id| [title.titleize, id] }
  end

  def set_type
    @type = params[:type]
  end

  def set_tutorial
    @tutorial = tutorial_class.find(params[:id])
  end

  def tutorial_class
    case @type
    when 'PDF'
      PdfTutorial
    when 'Video'
      VideoTutorial
    when 'FAQ'
      FaqTutorial
    end
  end
end
