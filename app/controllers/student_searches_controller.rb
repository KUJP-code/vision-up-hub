# frozen_string_literal: true

class StudentSearchesController < ApplicationController
  def index
    return render_parent_form unless params[:commit]

    search_params[:parent_id] ? parent_search : staff_search
  end

  # We need this to dodge the pundit auth on the StudentsController version
  # Since it's often a parent searching for their unclaimed child
  # by definition they won't have authorisation as the parent_id will be nil
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
    strong_params = params.require(:search).permit(%i[birthday level school_id student_id parent_id])
    strong_params if current_user.is?('Parent')

    strong_params.compact_blank
  end

  def update_params
    params.require(:student).permit(:student_id, :level, :parent_id)
  end

  def parent_search
    @results = Student.where(
      birthday: search_params[:birthday],
      student_id: search_params[:student_id]
    )
    @parent_id = search_params[:parent_id]

    if @results.empty?
      render_parent_form(failed: true)
    else
      render partial: 'student_searches/results',
             locals: {
               parent_id: @parent_id,
               results: @results
             }
    end
  end

  def render_parent_form(failed: false)
    parent_id = params[:parent_id] || search_params[:parent_id]
    schools = Parent.find(parent_id).organisation.schools.pluck(:name, :id)

    render partial: 'student_searches/parent_form',
           locals: { failed:, parent_id:, schools: }
  end

  def staff_search
    @results = policy_scope(Student).where(search_params)
                                    .includes(:school)
    render partial: 'students/table',
           locals: { students: @results }
  end
end
