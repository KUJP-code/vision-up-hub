# frozen_string_literal: true

class StudentSearchesController < ApplicationController
  def index
    render partial: 'student_searches/form',
           locals: { parent_id: params[:parent_id] }
  end

  def create
    search_params[:parent_id] ? parent_search : staff_search
  end

  def update
    @student = Student.find_by(
      id: params[:id],
      student_id: update_params[:student_id],
      level: update_params[:level]
    )
    @parent = Parent.find(update_params[:parent_id])

    @parent.children << @student
    redirect_to organisation_parent_path(@parent.organisation, @parent),
                notice: t('update_success')
  end

  private

  def search_params
    if current_user.is?('Parent')
      params.require(:search).permit(:level, :student_id, :parent_id)
    else
      params.require(:search).permit(:level, :name, :school_id, :student_id)
    end
  end

  def update_params
    params.require(:student).permit(:student_id, :level, :parent_id)
  end

  def parent_search
    @results = Student.where(
      student_id: search_params[:student_id],
      level: search_params[:level]
    )
    @parent_id = search_params[:parent_id]

    render partial: 'student_searches/results',
           locals: {
             parent_id: @parent_id,
             results: @results
           }
  end
end
