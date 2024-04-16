# frozen_string_literal: true

class StudentUploadsController < ApplicationController
  after_action :verify_authorized, only: %i[create new update]

  def new
    @organisation = authorize Organisation.find(params[:organisation_id])
    @orgs = policy_scope(Organisation) if current_user.is?('Admin')
  end

  def create
    @student = authorize Student.new(student_upload_params)

    if @student.save
      # render a turbo stream success partial
    else
      @errors = @student.errors
      # render a turbo stream error partial
    end
  end

  def update
    @student = Student.find_by(
      student_id: student_upload_params[:student_id],
      school_id: student_upload_params[:school_id]
    )

    if @student.update(student_upload_params)
      # render a turbo stream success partial
    else
      @errors = @student.errors
      # render a turbo stream error partial
    end
  end

  private

  def student_upload_params
    params.require(:student_upload).permit(:level, :name, :school_id, :student_id, :parent_id)
  end
end
