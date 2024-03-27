# frozen_string_literal: true

class StudentSearchesController < ApplicationController
  def index
    render partial: 'student_searches/parent_form',
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
    strong_params = params.require(:search).permit(%i[level school_id student_id parent_id])
    strong_params if current_user.is?('Parent')

    strong_params.compact_blank
  end

  def update_params
    params.require(:student).permit(:student_id, :level, :parent_id)
  end

  def parent_search
    @results = Student.where(
      level: search_params[:level],
      school_id: search_params[:school_id],
      student_id: search_params[:student_id]
    )
    @parent_id = search_params[:parent_id]

    if @results.empty?
      render partial: 'student_searches/parent_form',
             locals: { failed: true, parent_id: @parent_id }
    else
      render partial: 'student_searches/results',
             locals: {
               parent_id: @parent_id,
               results: @results
             }
    end
  end

  def staff_search
    @results = policy_scope(Student).where(search_params)
                                    .includes(:school)
    render partial: 'students/table',
           locals: { students: @results }
  end
end
