# frozen_string_literal: true

class TutorialSectionsController < ApplicationController
  before_action :set_tutorial_section, only: %i[edit update destroy]
  after_action :verify_authorized

  def new
    @tutorial_section = authorize TutorialSection.new
  end

  def edit; end

  def create
    @tutorial_section = authorize TutorialSection.new(tutorial_section_params.merge(position: next_position))
    if @tutorial_section.save
      redirect_to tutorials_path, notice: 'Section was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @tutorial_section.update(tutorial_section_params)
      redirect_to tutorials_path(section: @tutorial_section.id), notice: 'Section was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @tutorial_section.destroy
    redirect_to tutorials_path, notice: 'Section was successfully deleted. Its categories are now in Others.'
  end

  def reorder
    authorize TutorialSection, :update?
    ordered_ids = Array(params[:tutorial_section_ids])
    sections = TutorialSection.where(id: ordered_ids).index_by { |section| section.id.to_s }
    TutorialSection.transaction do
      ordered_ids.each_with_index { |id, position| sections[id.to_s]&.update!(position:) }
    end
    head :no_content
  end

  private

  def set_tutorial_section
    @tutorial_section = authorize TutorialSection.find(params[:id])
  end

  def tutorial_section_params
    params.require(:tutorial_section).permit(:title, :cover_image)
  end

  def next_position
    (TutorialSection.maximum(:position) || -1) + 1
  end
end
