# frozen_string_literal: true

class StudentUploadsController < ApplicationController
  after_action :verify_authorized, only: %i[create new update]

  def new
    authorize nil, policy_class: StudentUploadPolicy
    @organisation = authorize(Organisation.find(params[:organisation_id]), :update?)
    @orgs = policy_scope(Organisation) if current_user.is?('Admin')
  end

  def create
    @student = authorize Student.new(student_upload_params)
    @index = params[:index].to_i
    @status = 'Uploaded'
    return if @student.save

    set_errors
  end

  def update
    @student = authorize Student.find_by(
      student_id: student_upload_params[:student_id],
      school_id: student_upload_params[:school_id]
    )
    @index = params[:index].to_i
    @status = 'Uploaded'
    return if @student.update(student_upload_params)

    set_errors
  end

  private

  def student_upload_params
    params.require(:student_upload).permit(
      :birthday, :level, :name, :parent_id, :quit_date, :school_id, :start_date, :student_id
    )
  end

  def set_errors
    @errors = @student.errors.full_messages.to_sentence
    @schools = policy_scope(School).pluck(:name, :id)
    @status = 'Error'
  end
end
