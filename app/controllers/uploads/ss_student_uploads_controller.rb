# frozen_string_literal: true

class SsStudentUploadsController < ApplicationController
  include SampleCsvable

  after_action :verify_authorized, only: %i[create new show update]

  def show
    authorize nil, policy_class: StudentUploadPolicy
    send_data sample_csv(Student::SS_CSV_HEADERS),
              filename: 'sample_students_upload.csv'
  end

  def new
    authorize nil, policy_class: StudentUploadPolicy
    @organisation = authorize(Organisation.find(params[:organisation_id]), :update?)
    @orgs = policy_scope(Organisation)

  end

  def create
    Rails.logger.info "Params received: #{params.inspect}"
    @organisation = Organisation.find(params[:organisation_id])
    @school = @organisation.schools.find(params[:school_id])
    @student = authorize Student.new(student_upload_params)
    @index = params[:index].to_i
    @status = 'Uploaded'
    return if @student.save

    set_errors
  end

  def update
    @organisation = Organisation.find(params[:organisation_id])
    @school = @organisation.schools.find(params[:school_id])
    @student = authorize Student.find_by(
      student_id: student_upload_params[:student_id],
      school_id: student_upload_params[:school_id]
    )
    @index = params[:index].to_i
    @status = 'Uploaded'
    Logidze.with_responsible(current_user.id) do
      return if @student.update(student_upload_params)
    end

    set_errors
  end

  private

  def student_upload_params
    params.require(:student_upload).permit(Student::SS_CSV_HEADERS.map(&:to_sym))
  end

  def set_errors
    @errors = @student.errors.full_messages.to_sentence
    @schools = policy_scope(School).pluck(:name, :id)
    @status = 'Error'
  end
end
